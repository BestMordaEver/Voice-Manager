local https = require "coro-http"
local json = require "json"
local timer = require "timer"

--[[
local token = "Bot "..require "token".tokenTrue
local id = "601347755046076427" -- vm
--]]

-- [[
local token = "Bot "..require "token".token
local id = "676787135650463764" -- rat
--]]

--local guild = "669676999211483144" -- playground
--local guild = "741645965869711410" -- test
local guild = "273094432377667586" -- the last bastion

local domain = "https://discord.com/api/v10"
local GLOBAL_COMMANDS = string.format("%s/applications/%s/commands", domain, id)
local GLOBAL_COMMAND = string.format("%s/applications/%s/commands/%s", domain, id,"%s")
local GUILD_COMMANDS = string.format("%s/applications/%s/guilds/%s/commands", domain, id, "%s")
local GUILD_COMMAND = string.format("%s/applications/%s/guilds/%s/commands/%s", domain, id, "%s", "%s")

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

	if res['x-ratelimit-remaining'] == '0' then
		delay = math.max(1000 * res['x-ratelimit-reset-after'], delay)
	end

	local data = json.decode(msg, 1, json.null)

	if res.code < 300 then
		printf('SUCCESS : %i - %s : %s %s', res.code, res.reason, method, url)
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

local enums = require "discordia".enums
local commandType = enums.applicationCommandType
local commandOptionType = enums.applicationCommandOptionType

local commandsStructure = {
	require "slash/help",
	require "slash/lobby",
	require "slash/matchmaking",
	require "slash/companion",
	require "slash/room",
	require "slash/server",
	require "slash/reset",
	require "slash/clone",
	require "slash/delete",
	require "slash/users",
	{
		name = "support",
		description = "Send invite to the support server",
	},
	{
		name = "ping",
		description = "Check up on bot's status!"
	},
	{
		name = "Invite",
		type = commandType.user
	},
	--[[{
		name = "Clear messages above",
		type = commandType.message
	},
	{
		name = "Clear messages below",
		type = commandType.message
	}]]
}

local debugCommands = {
	{
		name = "exec",
		description = "This is gonna be our little secret",
		options = {
			{
				name = "code",
				description = "What do you want me to do?",
				type = commandOptionType.string,
				required = true
			}
		}
	},
	{
		name = "shutdown",
		description = "Guess I'll die",
	}
}

coroutine.wrap(function ()
	print(CommandManager.overwriteGlobalCommands(commandsStructure))
	--print(CommandManager.overwriteGuildCommands(guild, commandsStructure))
	--for _,command in ipairs(debugCommands) do print(CommandManager.createGuildCommand(guild, command)) end
	--print(CommandManager.getGlobalCommands()[1].version)
end)()

return CommandManager