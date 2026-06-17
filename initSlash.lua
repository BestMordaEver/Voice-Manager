local https = require "coro-http"
local json = require "json"
local timer = require "timer"
local base64 = require "base64"

-- ────────────────────────────────────────────────────────────────────────────
-- Slash command setup
-- ────────────────────────────────────────────────────────────────────────────
-- Interactive helper for installing the bot's slash commands. Pick an action
-- from the menu — there is no need to edit this file. Installing or updating
-- reconciles the live command set with the definitions in slash/init, touching
-- only what actually changed, so users never see an "outdated command" error.
-- Run it once whenever the command structure changes.

local domain = "https://discord.com/api/v10"

-- Selected application. Filled in by useApplication() once a token is chosen, so
-- the CommandManager closures below read these upvalues at call time.
local token, id
local GLOBAL_COMMANDS, GLOBAL_COMMAND, GUILD_COMMANDS, GUILD_COMMAND

local function useApplication (rawToken, appId)
	token = "Bot "..rawToken
	id = appId
	GLOBAL_COMMANDS = string.format("%s/applications/%s/commands", domain, id)
	GLOBAL_COMMAND  = string.format("%s/applications/%s/commands/%s", domain, id, "%s")
	GUILD_COMMANDS  = string.format("%s/applications/%s/guilds/%s/commands", domain, id, "%s")
	GUILD_COMMAND   = string.format("%s/applications/%s/guilds/%s/commands/%s", domain, id, "%s", "%s")
end

-- The application id is the first dot-separated segment of a bot token, encoded
-- as base64url. Normalise to padded standard base64 before decoding so tokens of
-- any length (and with url-safe characters) resolve correctly.
local function appIdFromToken (rawToken)
	local segment = tostring(rawToken):match("^[^.]+")
	if not segment then return nil end
	segment = segment:gsub("-", "+"):gsub("_", "/")
	segment = segment .. string.rep("=", (4 - #segment % 4) % 4)
	local ok, decoded = pcall(base64.decode, segment)
	if ok and decoded and decoded:match("^%d+$") then
		return decoded
	end
end

local printf = function (...)
	print(string.format(...))
end

local function parseErrors(ret, errors, key)
	for k, v in pairs(errors) do
		if k == '_errors' then
			for _, err in ipairs(v) do
				table.insert(ret, string.format('%s in %s : %s', err.code, key or 'payload', err.message))
			end
		else
			if key then
				parseErrors(ret, v, string.format(k:find("^[%a_][%a%d_]*$") and '%s.%s' or tonumber(k) and '%s[%d]' or '%s[%q]', key, k))
			else
				parseErrors(ret, v, k)
			end
		end
	end
	return table.concat(ret, '\n\t')
end

local function request (method, url, payload, retries)
	local success, res, msg = pcall(https.request, method, url,
		{{"Authorization", token},{"Content-Type", "application/json"},{"Accept", "application/json"}}, payload and json.encode(payload))
	local delay, maxRetries = 300, 5
	retries = retries or 0

	if not success then
		return nil, res
	end

	for i, v in ipairs(res) do
		res[v[1]:lower()] = v[2]
		res[i] = nil
	end

	-- The bucket is empty: the *next* request on this route would 429, so wait
	-- for it to reset before returning. reset-after is the seconds until refill.
	local exhausted = res['x-ratelimit-remaining'] == '0' and res['x-ratelimit-reset-after']
	if exhausted then
		delay = math.max(1000 * res['x-ratelimit-reset-after'], delay)
	end

	local data = json.decode(msg, 1, json.null)

	if res.code < 300 then
		printf('SUCCESS : %i - %s : %s %s', res.code, res.reason, method, url)
		if exhausted then
			printf('THROTTLE : bucket empty, waiting %i ms : %s %s', delay, method, url)
			timer.sleep(delay)
		end
		return data or true, nil
	else
		if type(data) == 'table' then

			local retry
			if res.code == 429 then -- TODO: global ratelimiting
				delay = data.retry_after*1000
				retry = retries < maxRetries
			elseif res.code == 502 then
				delay = delay + math.random(2000)
				retry = retries < maxRetries
			end

			if retry then
				printf('WARNING : %i - %s : retrying after %i ms : %s %s', res.code, res.reason, delay, method, url)
				timer.sleep(delay)
				return request(method, url, payload, retries + 1)
			end

			if data.code and data.message then
				msg = string.format('HTTP ERROR %i : %s', data.code, data.message)
			else
				msg = 'HTTP ERROR'
			end
			if data.errors then
				msg = parseErrors({msg}, data.errors)
			end

			printf('ERROR : %i - %s : %s %s', res.code, res.reason, method, url)
			return nil, msg, delay
		end
	end
end

local CommandManager = {
	getGlobalCommands = function ()
		return request("GET", GLOBAL_COMMANDS)
	end,

	getGlobalCommand = function (id)
		return request("GET", GLOBAL_COMMAND:format(id))
	end,

	createGlobalCommand = function (payload)
		return request("POST", GLOBAL_COMMANDS, payload)
	end,

	editGlobalCommand = function (id, payload)
		return request("PATCH", GLOBAL_COMMAND:format(id), payload)
	end,

	editGlobalCommands = function (payload)
		return request("PATCH", GLOBAL_COMMANDS, payload)
	end,

	deleteGlobalCommand = function (id)
		return request("DELETE", GLOBAL_COMMAND:format(id))
	end,

	overwriteGlobalCommands = function(payload)
		return request("PUT", GLOBAL_COMMANDS, payload)
	end,

	getGuildCommands = function (guild)
		return request("GET", GUILD_COMMANDS:format(guild))
	end,

	getGuildCommand = function (guild, id)
		return request("GET", GUILD_COMMAND:format(guild, id))
	end,

	createGuildCommand = function (guild, payload)
		return request("POST", GUILD_COMMANDS:format(guild), payload)
	end,

	editGuildCommand = function (guild, id, payload)
		return request("PATCH", GUILD_COMMAND:format(guild, id), payload)
	end,

	editGuildCommands = function (guild, payload)
		return request("PATCH", GUILD_COMMANDS:format(guild), payload)
	end,

	deleteGuildCommand = function (guild, id)
		return request("DELETE", GUILD_COMMAND:format(guild, id))
	end,

	overwriteGuildCommands = function(guild, payload)
		return request("PUT", GUILD_COMMANDS:format(guild), payload)
	end
}

local commands = require "slash/init"

-- ────────────────────────────────────────────────────────────────────────────
-- Reconciliation
-- ────────────────────────────────────────────────────────────────────────────
-- Rather than overwriting the whole command set (which briefly invalidates every
-- command), we compare the desired definitions against what Discord currently
-- has and touch only the differences.

-- Normalise a localization map: drop entries that are absent, null, or identical
-- to the base value (Discord silently strips redundant localizations, so keeping
-- them would make every command look "changed"). Returns nil when nothing useful
-- remains.
local function normLoc(map, base)
	if type(map) ~= "table" then return nil end
	local out, has = {}, false
	for k, v in pairs(map) do
		if v ~= json.null and v ~= base then
			out[k] = v
			has = true
		end
	end
	if has then return out end
end

-- Collapse empty/null tables to nil so "absent" and "empty" compare equal.
local function normList(list)
	if type(list) == "table" and #list > 0 then return list end
end

-- Build a canonical, comparable representation of a command option. The same
-- transformation is applied to both the desired payload and the live command, so
-- defaults Discord fills in (required=false, etc.) never register as changes.
local function canonOption(o)
	local c = {
		type = o.type,
		name = o.name,
		description = o.description,
		required = o.required or false,
		autocomplete = o.autocomplete or false,
		min_value = o.min_value,
		max_value = o.max_value,
		min_length = o.min_length,
		max_length = o.max_length,
		channel_types = normList(o.channel_types),
		name_localizations = normLoc(o.name_localizations, o.name),
		description_localizations = normLoc(o.description_localizations, o.description),
	}

	local choices = normList(o.choices)
	if choices then
		c.choices = {}
		for i, ch in ipairs(choices) do
			c.choices[i] = {
				name = ch.name,
				value = ch.value,
				name_localizations = normLoc(ch.name_localizations, ch.name),
			}
		end
	end

	local opts = normList(o.options)
	if opts then
		c.options = {}
		for i, sub in ipairs(opts) do c.options[i] = canonOption(sub) end
	end

	return c
end

local function canonCommand(cmd)
	local c = {
		type = cmd.type or 1,
		name = cmd.name,
		description = cmd.description or "",
		name_localizations = normLoc(cmd.name_localizations, cmd.name),
		description_localizations = normLoc(cmd.description_localizations, cmd.description),
	}

	local opts = normList(cmd.options)
	if opts then
		c.options = {}
		for i, o in ipairs(opts) do c.options[i] = canonOption(o) end
	end

	return c
end

local function deepEqual(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for k, v in pairs(a) do
		if not deepEqual(v, b[k]) then return false end
	end
	for k in pairs(b) do
		if a[k] == nil then return false end
	end
	return true
end

-- Commands are uniquely identified by their (type, name) pair.
local function commandKey(cmd)
	return string.format("%i:%s", cmd.type or 1, cmd.name)
end

-- Reconcile a list of desired commands against the live set returned by getExisting.
-- create/edit are scope-specific wrappers around CommandManager. Commands that
-- exist live but aren't in `desired` are left untouched, so several independent
-- command sets (e.g. the normal set and the admin set) can coexist on one guild.
local function reconcile(scope, desired, getExisting, create, edit)
	local existing, err = getExisting()
	if not existing then
		printf("ABORTED : %s : could not fetch existing commands : %s", scope, tostring(err))
		return false
	end

	local live = {}
	for _, cmd in ipairs(existing) do
		live[commandKey(cmd)] = cmd
	end

	local created, updated, unchanged = 0, 0, 0

	for _, cmd in ipairs(desired) do
		local current = live[commandKey(cmd)]

		if not current then
			if create(cmd) then created = created + 1 end
		elseif not deepEqual(canonCommand(cmd), canonCommand(current)) then
			if edit(current.id, cmd) then updated = updated + 1 end
		else
			unchanged = unchanged + 1
		end
	end

	printf("DONE : %s : %i created, %i updated, %i unchanged",
		scope, created, updated, unchanged)
	return true
end

-- ────────────────────────────────────────────────────────────────────────────
-- Scope-bound reconcile helpers
-- ────────────────────────────────────────────────────────────────────────────
local function reconcileGlobal ()
	return reconcile("global", commands[1],
		CommandManager.getGlobalCommands,
		CommandManager.createGlobalCommand,
		CommandManager.editGlobalCommand)
end

local function reconcileGuild (guild, desired, label)
	return reconcile(label, desired,
		function () return CommandManager.getGuildCommands(guild) end,
		function (payload) return CommandManager.createGuildCommand(guild, payload) end,
		function (cmdId, payload) return CommandManager.editGuildCommand(guild, cmdId, payload) end)
end

-- ────────────────────────────────────────────────────────────────────────────
-- Interactive prompt (works with both interactive and piped stdin)
-- ────────────────────────────────────────────────────────────────────────────
local inputBuffer = ""
local pending

local function pump ()
	while pending do
		local s, e = inputBuffer:find("\r?\n")
		if not s then break end
		local line = inputBuffer:sub(1, s - 1)
		inputBuffer = inputBuffer:sub(e + 1)
		local cb = pending
		pending = nil
		cb(line)
	end
end

process.stdin:on('data', function (chunk)
	inputBuffer = inputBuffer .. chunk
	pump()
end)

local function prompt (text, cb)
	io.write(text)
	pending = cb
	pump()
end

local function trim (s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Forward declaration so the action handlers can return to the menu.
local showMenu

-- Run a (possibly network-bound) action in a coroutine, then redraw the menu.
local function run (fn)
	coroutine.wrap(function ()
		local ok, err = pcall(fn)
		if not ok then printf("ERROR : %s", tostring(err)) end
		print("")
		showMenu()
	end)()
end

local function askGuild (action)
	prompt("Server (guild) id: ", function (line)
		local guild = trim(line)
		if guild:match("^%d+$") then
			action(guild)
		else
			print("That doesn't look like a server id (digits only). Cancelled.\n")
			showMenu()
		end
	end)
end

local function confirm (text, action)
	prompt(text.." [y/N]: ", function (line)
		if trim(line):lower() == "y" then
			action()
		else
			print("Cancelled.\n")
			showMenu()
		end
	end)
end

-- Human-readable suffix for the non-default command types (chat input has none).
local function typeSuffix (cmd)
	if cmd.type == 2 then return "  (user)" end
	if cmd.type == 3 then return "  (message)" end
	return ""
end

-- Fetch the live commands in a scope, list them, let the user pick one by
-- number, confirm, then delete just that command.
local function deleteOne (scope, getExisting, delete)
	coroutine.wrap(function ()
		local existing, err = getExisting()
		if not existing then
			printf("ABORTED : %s : could not fetch commands : %s", scope, tostring(err))
			print("")
			return showMenu()
		end
		if #existing == 0 then
			printf("No commands found in %s.\n", scope)
			return showMenu()
		end

		print("Commands in "..scope..":")
		for i, cmd in ipairs(existing) do
			printf("  [%i] %s%s", i, cmd.name, typeSuffix(cmd))
		end
		prompt("Delete which? (number, blank to cancel) ", function (line)
			local pick = existing[tonumber(trim(line)) or 0]
			if not pick then
				print("Cancelled.\n")
				return showMenu()
			end
			confirm(string.format("Delete /%s?", pick.name), function ()
				run(function ()
					local ok = delete(pick.id)
					printf("DONE : %s : %s", scope, ok and ("deleted "..pick.name) or "failed")
				end)
			end)
		end)
	end)()
end

local actions = {
	["1"] = function ()
		run(reconcileGlobal)
	end,

	["2"] = function ()
		askGuild(function (guild)
			run(function () reconcileGuild(guild, commands[1], "guild "..guild) end)
		end)
	end,

	["3"] = function ()
		askGuild(function (guild)
			run(function () reconcileGuild(guild, commands[2], "admin commands in guild "..guild) end)
		end)
	end,

	["4"] = function ()
		deleteOne("global", CommandManager.getGlobalCommands, CommandManager.deleteGlobalCommand)
	end,

	["5"] = function ()
		askGuild(function (guild)
			deleteOne("guild "..guild,
				function () return CommandManager.getGuildCommands(guild) end,
				function (cmdId) return CommandManager.deleteGuildCommand(guild, cmdId) end)
		end)
	end,

	["6"] = function ()
		confirm("Remove ALL global commands?", function ()
			run(function ()
				local ok = CommandManager.overwriteGlobalCommands({})
				printf("DONE : global : %s", ok and "all commands removed" or "failed")
			end)
		end)
	end,

	["7"] = function ()
		askGuild(function (guild)
			confirm("Remove ALL commands from guild "..guild.."?", function ()
				run(function ()
					local ok = CommandManager.overwriteGuildCommands(guild, {})
					printf("DONE : guild %s : %s", guild, ok and "all commands removed" or "failed")
				end)
			end)
		end)
	end,
}

showMenu = function ()
	print("Voice Manager — slash command setup")
	print("Bot application id: "..tostring(id))
	print("")
	print("  [1] Install / update standard commands globally       (production; up to ~1h to appear)")
	print("  [2] Install / update standard commands in one server  (instant; ideal for testing)")
	print("  [3] Install / update admin commands in one server     (/exec and /shutdown)")
	print("  [4] Delete a single global command")
	print("  [5] Delete a single command from one server")
	print("  [6] Remove ALL global commands")
	print("  [7] Remove ALL commands from one server")
	print("  [q] Quit")
	prompt("> ", function (line)
		local choice = trim(line):lower()
		if choice == "q" or choice == "quit" then
			print("Bye!")
			os.exit(0)
		end
		local action = actions[choice]
		if action then
			action()
		else
			print("Unknown option.\n")
			showMenu()
		end
	end)
end

-- ────────────────────────────────────────────────────────────────────────────
-- Choose which bot to configure, then show the menu
-- ────────────────────────────────────────────────────────────────────────────
-- Every non-empty string field in token.lua is treated as a bot token. A normal
-- release only defines `token`, so the choice is made automatically; multi-bot
-- setups (extra fields) get a one-time selection prompt instead.
local tokenModule = require "token"
local availableTokens = {}
for label, value in pairs(tokenModule) do
	if type(value) == "string" and value ~= "" then
		local appId = appIdFromToken(value)
		if appId then
			availableTokens[#availableTokens + 1] = {label = label, token = value, id = appId}
		end
	end
end
table.sort(availableTokens, function (a, b) return a.label < b.label end)

local function start (chosen)
	useApplication(chosen.token, chosen.id)
	print("")
	showMenu()
end

if #availableTokens == 0 then
	print("No usable bot token found in token.lua. Add your token and run this again.")
	os.exit(1)
elseif #availableTokens == 1 then
	start(availableTokens[1])
else
	print("Multiple bot tokens found in token.lua:")
	for i, t in ipairs(availableTokens) do
		printf("  [%i] %s  (application id %s)", i, t.label, t.id)
	end
	prompt("Which bot? ", function (line)
		local pick = availableTokens[tonumber(trim(line)) or 0]
		if pick then
			start(pick)
		else
			print("Invalid choice. Run the script again.")
			os.exit(1)
		end
	end)
end