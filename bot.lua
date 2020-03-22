local discordia = require "discordia"
local config = require "./config.lua"
local https = require "coro-http"
local json = require "json"
local conn = require "sqlite3".open("data.db")
local locale = require "./locale.lua"

local client = discordia.Client()
local clock = discordia.Clock()
local logger = discordia.Logger(4, '%F %T')
local permission, channelType = discordia.enums.permission, discordia.enums.channelType

local stats = {lobbies = 0, channels = 0, people = 0}

local function safeEvent (name, fn)
	return name, function (...)
		local success, err = pcall(fn, ...)
		if not success then
			logger:log(1, "Error on "..name..": "..err)
			client:getChannel("686261668522491980"):send("Error on "..name..": "..err)
		end
	end
end

local channels, lobbies, servers
channels = setmetatable({}, {
	__index = {
		add = function (self, channelID)
			if not self[channelID] then
				self[channelID] = true
				stats.channels = stats.channels + 1
				logger:log(4, "MEMORY: Added channel "..channelID)
			end
			if not conn:exec("SELECT * FROM channels WHERE id = "..channelID) then
				local res = pcall(function() conn:exec("INSERT INTO channels VALUES("..channelID..")") end)
				if res then logger:log(4, "DATABASE: Added channel "..channelID) end
			end
		end,
		
		remove = function (self, channelID)
			if self[channelID] then
				self[channelID] = nil
				stats.channels = stats.channels - 1
				logger:log(4, "MEMORY: Deleted channel "..channelID)
			end
			if conn:exec("SELECT * FROM channels WHERE id = "..channelID) then
				local res = pcall(function() conn:exec("DELETE FROM channels WHERE id = "..channelID) end)
				if res then logger:log(4, "DATABASE: Deleted channel "..channelID) end
			end
		end,
		
		load = function (self)
			logger:log(4, "Loading channels")
			local channelIDs = conn:exec("SELECT * FROM channels")
			if channelIDs then
				for _, channelID in ipairs(channelIDs[1]) do
					local channel = client:getChannel(channelID)
					if channel then
						self:add(channelID)
						stats.people = stats.people + #channel.connectedMembers
					else
						stats.channels = stats.channels + 1 -- remove decrements this, but it wasn't counted in yet
						self:remove(channelID)
					end
				end
			end
			logger:log(4, "Loaded!")
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs (self) do count = count + 1 end
		return count
	end
})

lobbies = setmetatable({}, {
	__index = {
		add = function (self, lobbyID)
			if channels[lobbyID] then channels:remove(lobbyID) end	-- I swear to god, there will be one crackhead
			
			if not self[lobbyID] then 
				self[lobbyID] = true
				stats.lobbies = stats.lobbies + 1
				logger:log(4, "MEMORY: Added lobby "..lobbyID)
			end
			if not conn:exec("SELECT * FROM lobbies WHERE id = "..lobbyID) then
				local res = pcall(function() conn:exec("INSERT INTO lobbies VALUES("..lobbyID..")") end)
				if res then logger:log(4, "DATABASE: Added lobby "..lobbyID) end
			end
		end,
		
		remove = function (self, lobbyID)
			if self[lobbyID] then
				self[lobbyID] = nil
				stats.lobbies = stats.lobbies - 1
				logger:log(4, "MEMORY: Deleted lobby "..lobbyID)
			end
			if conn:exec("SELECT * FROM lobbies WHERE id = "..lobbyID) then
				local res = pcall(function() conn:exec("DELETE FROM lobbies WHERE id = "..lobbyID) end)
				if res then logger:log(4, "DATABASE: Deleted lobby "..lobbyID) end
			end
		end,
		
		load = function (self)
			logger:log(4, "Loading lobbies")
			local lobbyIDs = conn:exec("SELECT * FROM lobbies")
			if lobbyIDs then
				for _, lobbyID in ipairs(lobbyIDs[1]) do
					if client:getChannel(lobbyID) then 
						self:add(lobbyID)
					else
						stats.lobbies = stats.lobbies + 1 -- remove decrements this, but it wasn't counted in yet
						self:remove(lobbyID)
					end
				end
			end
			logger:log(4, "Loaded!")
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs (self) do count = count + 1 end
		return count
	end
})

guilds = setmetatable({}, {
	__index = {
		add = function (self, guildID)
			if not self[guildID] then 
				self[guildID] = {locale = "english"}
				logger:log(4, "MEMORY: Added guild "..guildID)
			end
			if not conn:exec("SELECT * FROM guilds WHERE id = "..guildID) then
				local res = pcall(function() conn:exec("INSERT INTO guilds VALUES("..guildID..", 'english', NULL)") end)
				if res then logger:log(4, "DATABASE: Added guild "..guildID) end
			end
		end,
		
		remove = function (self, guildID)
			if self[guildID] then
				self[guildID] = nil
				stats.lobbies = stats.lobbies - 1
				logger:log(4, "MEMORY: Deleted guild "..guildID)
			end
			if conn:exec("SELECT * FROM guilds WHERE id = "..guildID) then
				local res = pcall(function() conn:exec("DELETE FROM guilds WHERE id = "..guildID) end)
				if res then logger:log(4, "DATABASE: Deleted guild "..guildID) end
			end
		end,
		
		load = function (self)
			logger:log(4, "Loading guilds from save")
			local guildIDs = conn:exec("SELECT * FROM guilds")
			if guildIDs then
				for i, guildID in ipairs(guildIDs[1]) do
					if client:getGuild(guildID) then
						self:add(guildID)
						self:updateLocale(guildID, guildIDs.locale[i])
						self:updatePrefix(guildID, guildIDs.prefix[i])
					else
						self:remove(guildID)
					end
				end
			end
			
			logger:log(4, "Loading guilds from client")
			for _, guild in pairs(client.guilds) do
				if not self[guild.id] then self:add(guild.id) end
			end
			
			logger:log(4, "Loaded!")
		end,
		
		updateLocale = function (self, guildID, locale)
			if locale then
				self[guildID].locale = locale
				conn:exec("UPDATE guilds SET locale = '"..locale.."' WHERE id = "..guildID)
				logger:log(4, "Updated locale for "..guildID)
			end
		end,
		
		updatePrefix = function (self, guildID, prefix)
			if prefix then
				self[guildID].prefix = prefix
				conn:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"):bind(prefix, guildID):step()
				logger:log(4, "Updated prefix for "..guildID)
			end
		end
	}
})

local statservers = {
	["discordbotlist.com"] = {
		endpoint = "https://discordbotlist.com/api/bots/601347755046076427/stats",
		body = "guilds"
	},
	
	["top.gg"] = {
		endpoint = "https://top.gg/api/bots/601347755046076427/stats",
		body = "server_count"
	},
	
	["botsfordiscord.com"] = {
		endpoint = "https://botsfordiscord.com/api/bot/601347755046076427",
		body = "server_count"
	},
	
	["discord.boats"] = {
		endpoint = "https://discord.boats/api/bot/601347755046076427",
		body = "server_count"
	},
	
	["bots.ondiscord.xyz"] = {
		endpoint = "https://bots.ondiscord.xyz/bot-api/bots/601347755046076427/guilds",
		body = "guildCount"
	},
	
	["discord.bots.gg"] = {
		endpoint = "https://discord.bots.gg/api/v1/bots/601347755046076427/stats",
		body = "guildCount"
	}
}

local commands = {
	help = "help",
	register = "register",
	unregister = "unregister",
	list = "list",
	shutdown = "shutdown",
	stats = "stats",
	support = "support",
	id = "id",
	language = "language",
	prefix = "prefix"
}

local actions
actions = {
	permCheck = function (message)
		if not message.member:hasPermission(permission.manageChannels) then
			logger:log(4, "Mention in vain")
			message:reply(string.format(locale[guilds[message.guild.id].locale].mentionInVain, message.author.mentionString))
			return false
		end
		
		return true
	end,

	regFilter = function (message, command) -- returns a table of all ids
		if not actions.permCheck(message) then return end
		
		logger:log(4, command.." action invoked")
		local id = message.content:match(command.."%s+(.-)$")
		if not id then
			logger:log(4, "Empty input")
			message:reply(locale[guilds[message.guild.id].locale].emptyInput)
			return
		end
		
		local ids = {}
		for ID in id:gmatch("%d+") do
			local channel = client:getChannel(ID)
			if channel and channel.type == channelType.voice and channel.guild == message.guild then
				table.insert(ids, ID)
			end
		end
		
		if #ids == 0 then
			id = id:lower()
			local channels = message.guild.voiceChannels:toArray("position", function (channel) 
				return channel.name:lower() == id and (command == commands.unregister and lobbies[channel.id] or command ~= commands.unregister)
			end)
			if #channels == 0 then
				logger:log(4, "Bad "..command.." input")
				message:reply(locale[guilds[message.guild.id].locale].badInput)
				return
			elseif #channels == 1 then
				ids[1] = channels[1].id
				return ids
			else
				logger:log(4, "Ambiguous "..command.." input")
				actions[commands.id](message, id)
				return
			end
		else
			return ids
		end
	end,

	[commands.help] = function (message)
		logger:log(4, "Help action invoked")
		message:reply(locale[guilds[message.guild.id].locale].helpText)
	end,
	
	[commands.register] = function (message)
		local ids = actions.regFilter(message, commands.register)
		if not ids then return end
		
		local msg = string.format(#ids == 1 and locale[guilds[message.guild.id].locale].registeredOne or locale[guilds[message.guild.id].locale].registeredMany, #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale[guilds[message.guild.id].locale].channelIDNameCategory or locale[guilds[message.guild.id].locale].channelIDName, channel.id, channel.name, channel.category.name).."\n"
			lobbies:add(channelID)
		end
		message:reply(msg)
		logger:log(4, "Registered "..table.concat(ids, " ").." successfully")
	end,

	[commands.unregister] = function (message)
		local ids = actions.regFilter(message, commands.unregister)
		if not ids then return end
		
		local msg = string.format(#ids == 1 and locale[guilds[message.guild.id].locale].unregisteredOne or locale[guilds[message.guild.id].locale].unregisteredMany, #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale[guilds[message.guild.id].locale].channelIDNameCategory or locale[guilds[message.guild.id].locale].channelIDName, channel.id, channel.name, channel.category.name).."\n"
			lobbies:remove(channelID)
		end
		message:reply(msg)
		logger:log(4, "Unregistered "..table.concat(ids, " ").." successfully")
	end,
	
	[commands.id] = function (message, target)
		if not actions.permCheck(message) then return end
		
		logger:log(4, "ID action invoked")
		local msg = target and (locale[guilds[message.guild.id].locale].ambiguousID.."\n") or ""
		target = target or message.content:match(commands.id.."%s+(.-)$")

		local channels = message.guild.voiceChannels:toArray()
		table.sort(channels, function (a, b)
			return (not a.category and b.category) or
				(a.category and b.category and a.category.position < b.category.position) or
				(a.category == b.category and a.position < b.position)
			end)
		
		for _, channel in ipairs(channels) do
			if target and (channel.name:lower() == target or (channel.category and channel.category.name:lower() == target)) or not target then
				msg = msg..string.format(channel.category and locale[guilds[message.guild.id].locale].channelIDNameCategory or locale[guilds[message.guild.id].locale].channelIDName, channel.id, channel.name, channel.category.name).."\n"
			end
		end
		
		if #msg > 2000 then
			msg = msg:sub(1,1949).."\n"..locale[guilds[message.guild.id].locale].bigMessage
		end
		
		message:reply(msg)
	end,
	
	[commands.language] = function (message)
		if not actions.permCheck(message) then return end
		logger:log(4, "Language action invoked")
		
		local lang = message.content:match(commands.language.."%s+(.-)$")
		if lang then 
			lang = lang:lower()
			for name, subLocale in pairs(locale) do
				if locale[lang] then break end
				for _, langName in pairs(subLocale.names) do
					if langName:lower() == lang:lower() then
						lang = name
						break
					end
				end
			end
		end
		
		if locale[lang] then
			guilds:updateLocale(message.guild.id, lang)
			message:reply(locale[guilds[message.guild.id].locale].updatedLocale)
		else
			logger:log(4, "No language '"..lang.."' found")
			local msg = locale[guilds[message.guild.id].locale].availableLanguages
			for _, lang in pairs(locale) do
				msg = msg.." "..lang.names[guilds[message.guild.id].locale]..","
			end
			msg = msg:sub(1,-2)
			message:reply(msg)
		end
	end,
	
	[commands.prefix] = function (message)
		if not actions.permCheck(message) then return end
		logger:log(4, "Prefix action invoked")
		
		local prefix = message.content:match(commands.prefix.."%s+(.-)$")
		
		if prefix then
			guilds:updatePrefix(message.guild.id, prefix)
			message:reply(string.format(locale[guilds[message.guild.id].locale].prefixConfirm, prefix))
		else
			message:reply(string.format(guilds[message.guild.id].prefix and locale[guilds[message.guild.id].locale].prefixThis or locale[guilds[message.guild.id].locale].prefixAbsent, guilds[message.guild.id].prefix))
		end
	end,
	
	[commands.list] = function (message)
		logger:log(4, "List action invoked")
		local lobbies = message.guild.voiceChannels:toArray("position", function (channel) return lobbies[channel.id] end)
		local msg = (#lobbies == 0 and locale[guilds[message.guild.id].locale].noLobbies or locale[guilds[message.guild.id].locale].someLobbies) .. "\n"
		for _,channel in ipairs(lobbies) do
			msg = msg..string.format(channel.category and locale[guilds[message.guild.id].locale].channelIDNameCategory or locale[guilds[message.guild.id].locale].channelIDName, channel.id, channel.name, channel.category.name).."\n"
		end
		message:reply(msg)
	end,
	
	[commands.shutdown] = function (message)
		if message then
			if message.author.id ~= "188731184501620736" then return end
			message:reply("Shutting down gracefully")
			logger:log(4, "Shutdown action invoked")
		end
		client:setGame({name = "the maintenance", type = 3})
		local status, msg = pcall(function()
			clock:stop()
			client:stop()
			--conn:close()
		end)
		logger:log(3, (status and "Shutdown successfull" or ("Couldn't shutdown gracefully, "..msg)))
		process:exit()
	end,
	
	[commands.stats] = function (message)
		local t = os.clock()
		message.channel:broadcastTyping()
		t = math.modf((os.clock() - t)*1000)
		logger:log(4, "Stats action invoked")
		message:reply(string.format(
			(#client.guilds == 1 and stats.lobbies == 1) and locale[guilds[message.guild.id].locale].serverLobby or (
			#client.guilds == 1 and locale[guilds[message.guild.id].locale].serverLobbies or (
			stats.lobbies == 1 and locale[guilds[message.guild.id].locale].serversLobby or 
			locale[guilds[message.guild.id].locale].serversLobbies)), #client.guilds, stats.lobbies) .. "\n" ..
		string.format(
			(stats.channels == 1 and stats.people == 1) and locale[guilds[message.guild.id].locale].channelPerson or (
			stats.channels == 1 and locale[guilds[message.guild.id].locale].channelPeople or (
			stats.people == 1 and locale[guilds[message.guild.id].locale].channelsPerson or -- practically impossible, but whatever
			locale[guilds[message.guild.id].locale].channelsPeople)), stats.channels, stats.people) .. "\n" ..
		string.format(locale[guilds[message.guild.id].locale].ping, t))
	end,
	
	[commands.support] = function (message)
		logger:log(4, "Support action invoked")
		message:reply("https://discord.gg/tqj6jvT")
	end
}

client:on(safeEvent('messageCreate', function (message)
	if message.channel.type ~= channelType.text and not message.author.bot then
		message:reply(locale[guilds[message.guild.id].locale].badChannel)
		return
	end
	
	if message.author.bot or (
		not message.mentionedUsers:find(function(user) return user == client.user end) and 
		not (guilds[message.guild.id].prefix and message.content:find(guilds[message.guild.id].prefix))) then
		return
	end
	
	logger:log(4, "Message received, processing...")
	if not message.guild.me:getPermissions(message.channel):has(permission.manageChannels, permission.moveMembers) then
		message:reply(locale[guilds[message.guild.id].locale].badPermissions)
	end
	
	local command = message.content:match("%s(%a+)")
	if not command then command = commands.help end
	local res, msg = pcall(function() if actions[command] then actions[command](message) end end)
	if not res then 
		logger:log(1, "Couldn't process the message, "..msg)
		client:getChannel("686261668522491980"):send("Couldn't process the message: "..message.content.."\n"..msg)
		message:reply(message.author.id ~= "188731184501620736"
			and (string.format(locale[guilds[message.guild.id].locale].error, os.date("%b %d %X")).."\nhttps://discord.gg/tqj6jvT")
			or "You done goofed")
	end
end))

client:on(safeEvent('guildCreate', function (guild)
	guilds:add(guild.id)
	client:getChannel("676432067566895111"):send(guild.name.." added me!\n")
end))

client:on(safeEvent('guildDelete', function (guild)
	guilds:remove(guild.id)
	for _,channel in pairs(guild.voiceChannels) do 
		if channels[channel.id] then channels:remove(channel.id) end 
		if lobbies[channel.id] then lobbies:remove(channel.id) end
	end
	client:getChannel("676432067566895111"):send(guild.name.." removed me!\n")
end))

client:on(safeEvent('voiceChannelJoin', function (member, channel)
	if lobbies[channel.id] then
		stats.people = stats.people + 1
		logger:log(4, member.user.id.." joined lobby "..channel.id)
		local category = channel.category or channel.guild
		local newChannel = category:createVoiceChannel((member.nickname or member.user.name).."'s channel")
		member:setVoiceChannel(newChannel.id)
		logger:log(4, "Created "..newChannel.id)
		channels:add(newChannel.id)
		newChannel:setUserLimit(channel.userLimit)
		if channel.guild.me:getPermissions(channel):has(permission.manageRoles, permission.manageChannels, permission.muteMembers, permission.deafenMembers, permission.moveMembers) then
			newChannel:getPermissionOverwriteFor(member):allowPermissions(permission.manageChannels, permission.muteMembers, permission.deafenMembers, permission.moveMembers)
		end
	end
end))

client:on(safeEvent('voiceChannelLeave', function (member, channel)
	if not channel then return end	-- until this is fixed
	if channels[channel.id] then
		stats.people = stats.people - 1
		if #channel.connectedMembers == 0 then
			channel:delete()
			logger:log(4, "Deleted "..channel.id)
		end
	end
end))

client:on(safeEvent('channelDelete', function (channel)
	lobbies:remove(channel.id)
	channels:remove(channel.id)
end))

client:on(safeEvent('ready', function()
	guilds:load()
	lobbies:load()
	channels:load()
	clock:start()
	client:getChannel("676432067566895111"):send("I'm listening")
end))

clock:on(safeEvent('min', function()
	client:getChannel("676791988518912020"):getLastMessage():delete()
	client:getChannel("676791988518912020"):send("beep boop beep")
	
	stats.people, stats.channels = 0, 0
	for channelID,_ in pairs(channels) do
		local channel = client:getChannel(channelID)
		if channel then
			if #channel.connectedMembers ~= 0 then
				stats.channels = stats.channels + 1
				stats.people = stats.people + #channel.connectedMembers
			else
				channel:delete()
			end
		end
	end
	
	client:setGame({name = stats.people == 0 and "the sound of silence" or (stats.people..(stats.people == 1 and " person" or " people").." on "..stats.channels..(stats.channels == 1 and " channel" or " channels")), type = 2})
	
	for name, guild in pairs(statservers) do
		client:emit("sendStats", name, guild)
	end
end))

client:on(safeEvent('sendStats', function(name, server)
	local res, body = https.request("POST",server.endpoint,
		{{"Authorization", config.tokens[name]},{"Content-Type", "application/json"},{"Accept", "application/json"}},
		json.encode({[server.body] = #client.guilds}))
	if res.code ~= 204 and res.code ~= 200 then 
		logger:log(2, "Couldn't send stats to %s - %s", name, body)
	end
end))

client:on(safeEvent('shutdown', actions[commands.shutdown]))

local sd = function () client:emit("shutdown") end -- ensures graceful shutdown

process:on('sigterm', sd)
process:on('sigint', sd)

client:run('Bot '..config.token)