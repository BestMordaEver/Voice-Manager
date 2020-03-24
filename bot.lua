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
local format, gmatch, match, lower, sub = string.format, string.gmatch, string.match, string.lower, string.sub
local insert, concat, sort = table.insert, table.concat, table.sort
local setmetatable, pcall, pairs, ipairs = setmetatable, pcall, pairs, ipairs

local function safeEvent (name, fn)
	return name, function (...)
		local success, err = pcall(fn, ...)
		if not success then
			logger:log(1, "Error on %s: %s", name, err)
			client:getChannel("686261668522491980"):sendf("Error on %s: %s", name, err)
		end
	end
end

local function truePositionSorting (a, b)
	return (not a.category and b.category) or
		(a.category and b.category and a.category.position < b.category.position) or
		(a.category == b.category and a.position < b.position)
end

local channels, lobbies, servers
channels = setmetatable({}, {
	__index = {
		add = function (self, channelID)
			if not self[channelID] then
				self[channelID] = true
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
					else
						self:remove(channelID)
					end
				end
			end
			logger:log(4, "Loaded!")
		end,
		
		people = function (self)
			local p = 0
			for channelID, _ in pairs(self) do
				p = p + #client:getChannel(channelID).connectedMembers
			end
			return p
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end
})

lobbies = setmetatable({}, {
	__index = {
		add = function (self, lobbyID)
			if channels[lobbyID] then channels:remove(lobbyID) end	-- I swear to god, there will be one crackhead
			
			if not self[lobbyID] then 
				self[lobbyID] = true
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
						self:remove(lobbyID)
					end
				end
			end
			logger:log(4, "Loaded!")
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end
})

guilds = setmetatable({}, {
	__index = {
		add = function (self, guildID)
			if not self[guildID] then 
				self[guildID] = {["locale"] = locale.english}
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
		
		updateLocale = function (self, guildID, localeName)
			if localeName then
				if self[guildID].locale ~= locale[localeName] then
					self[guildID].locale = locale[localeName]
					logger:log(4, "MEMORY: Updated locale for "..guildID)
				end
				if not conn:exec("SELECT guilds WHERE locale = '"..localeName.."', id = "..guildID) then
					conn:exec("UPDATE guilds SET locale = '"..localeName.."' WHERE id = "..guildID)
					logger:log(4, "DATABASE: Updated locale for "..guildID)
				end
			end
		end,
		
		updatePrefix = function (self, guildID, prefix)
			if prefix then
				if self[guildID].prefix ~= prefix then
					self[guildID].prefix = prefix
					logger:log(4, "MEMORY: Updated prefix for "..guildID)
				end
				if not conn:prepare("SELECT guilds WHERE prefix = ?, id = ?"):bind(prefix, guildID):step() then
					conn:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"):bind(prefix, guildID):step()	-- don't even think about it
					logger:log(4, "DATABASE: Updated prefix for "..guildID)
				end
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
			message:reply(format(guilds[message.guild.id].locale.mentionInVain, message.author.mentionString))
			return false
		end
		
		return true
	end,

	regFilter = function (message, command) -- returns a table of all ids
		if not actions.permCheck(message) then return end
		
		logger:log(4, command.." action invoked")
		local id = match(message.content, command.."%s+(.-)$")
		if not id then
			logger:log(4, "Empty input")
			message:reply(guilds[message.guild.id].locale.emptyInput)
			return
		end
		
		local ids = {}
		for ID in gmatch(id, "%d+") do
			local channel = client:getChannel(ID)
			if channel and channel.type == channelType.voice and channel.guild == message.guild then
				insert(ids, ID)
			end
		end
		
		if #ids == 0 then
			id = lower(id)
			local channels = message.guild.voiceChannels:toArray("position", function (channel) 
				return lower(channel.name) == id and (command == commands.unregister and lobbies[channel.id] or command ~= commands.unregister)
			end)
			if #channels == 0 then
				logger:log(4, "Bad "..command.." input")
				message:reply(guilds[message.guild.id].locale.badInput)
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
		message:reply(guilds[message.guild.id].locale.helpText)
	end,
	
	[commands.register] = function (message)
		local ids = actions.regFilter(message, commands.register)
		if not ids then return end
		
		local msg = format(#ids == 1 and guilds[message.guild.id].locale.registeredOne or guilds[message.guild.id].locale.registeredMany, #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..format(channel.category and guilds[message.guild.id].locale.channelIDNameCategory or guilds[message.guild.id].locale.channelIDName, channel.id, channel.name, channel.category.name).."\n"
			lobbies:add(channelID)
		end
		message:reply(msg)
		logger:log(4, "Registered "..concat(ids, " ").." successfully")
	end,

	[commands.unregister] = function (message)
		local ids = actions.regFilter(message, commands.unregister)
		if not ids then return end
		
		local msg = format(#ids == 1 and guilds[message.guild.id].locale.unregisteredOne or guilds[message.guild.id].locale.unregisteredMany, #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..format(channel.category and guilds[message.guild.id].locale.channelIDNameCategory or guilds[message.guild.id].locale.channelIDName, channel.id, channel.name, channel.category.name).."\n"
			lobbies:remove(channelID)
		end
		message:reply(msg)
		logger:log(4, "Unregistered "..concat(ids, " ").." successfully")
	end,
	
	[commands.id] = function (message, target)
		if not actions.permCheck(message) then return end
		logger:log(4, "ID action invoked")
		
		local msg = target and (guilds[message.guild.id].locale.ambiguousID.."\n") or ""
		target = target or match(message.content, commands.id.."%s+(.-)$")

		local channels = message.guild.voiceChannels:toArray(function (channel) 
			return target and (lower(channel.name) == target or (channel.category and channel.category.name:lower() == target)) or not target
		end)
		sort(channels, truePositionSorting)
		
		for _, channel in ipairs(channels) do
			msg = msg..format(channel.category and guilds[message.guild.id].locale.channelIDNameCategory or guilds[message.guild.id].locale.channelIDName, channel.id, channel.name, channel.category.name).."\n"
		end
		
		if #msg > 2000 then
			msg = sub(msg, 1,1949).."\n"..guilds[message.guild.id].locale.bigMessage
		end
		
		message:reply(msg)
	end,
	
	[commands.language] = function (message)
		if not actions.permCheck(message) then return end
		logger:log(4, "Language action invoked")
		
		local lang = lower(match(message.content, commands.language.."%s+(.-)$") or "")
		
		if locale[lang] then
			guilds:updateLocale(message.guild.id, lang)
			message:reply(guilds[message.guild.id].locale.updatedLocale)
		else
			logger:log(4, "No language '%s' found", lang)
			local msg = guilds[message.guild.id].locale.availableLanguages
			for langName, _ in pairs(locale) do
				msg = msg.." "..langName..","
			end
			msg = sub(msg, 1,-2)
			message:reply(msg)
		end
	end,
	
	[commands.prefix] = function (message)
		if not actions.permCheck(message) then return end
		logger:log(4, "Prefix action invoked")
		
		local prefix = match(message.content, commands.prefix.."%s+(.-)$")
		
		if prefix then
			guilds:updatePrefix(message.guild.id, prefix)
			message:reply(format(guilds[message.guild.id].locale.prefixConfirm, prefix))
		else
			message:reply(format(guilds[message.guild.id].prefix and guilds[message.guild.id].locale.prefixThis or guilds[message.guild.id].locale.prefixAbsent, guilds[message.guild.id].prefix))
		end
	end,
	
	[commands.list] = function (message)
		logger:log(4, "List action invoked")
		
		local lobbies = message.guild.voiceChannels:toArray(function (channel) return lobbies[channel.id] end)
		sort(lobbies, truePositionSorting)
		
		local msg = (#lobbies == 0 and guilds[message.guild.id].locale.noLobbies or guilds[message.guild.id].locale.someLobbies) .. "\n"
		for _,channel in ipairs(lobbies) do
			msg = msg..format(channel.category and guilds[message.guild.id].locale.channelIDNameCategory or guilds[message.guild.id].locale.channelIDName, channel.id, channel.name, channel.category.name).."\n"
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
		message:reply(format(
			(#client.guilds == 1 and #lobbies == 1) and guilds[message.guild.id].locale.serverLobby or (
			#client.guilds == 1 and guilds[message.guild.id].locale.serverLobbies or (
			#lobbies == 1 and guilds[message.guild.id].locale.serversLobby or 
			guilds[message.guild.id].locale.serversLobbies)), #client.guilds, #lobbies) .. "\n" ..
		format(
			(#channels == 1 and channels:people() == 1) and guilds[message.guild.id].locale.channelPerson or (
			#channels == 1 and guilds[message.guild.id].locale.channelPeople or (
			channels:people() == 1 and guilds[message.guild.id].locale.channelsPerson or -- practically impossible, but whatever
			guilds[message.guild.id].locale.channelsPeople)), #channels, channels:people()) .. "\n" ..
		format(guilds[message.guild.id].locale.ping, t))
	end,
	
	[commands.support] = function (message)
		logger:log(4, "Support action invoked")
		message:reply("https://discord.gg/tqj6jvT")
	end
}

client:on(safeEvent('messageCreate', function (message)
	if message.channel.type ~= channelType.text and not message.author.bot then
		message:reply(guilds[message.guild.id].locale.badChannel)
		return
	end
	
	if message.author.bot or (
		not message.mentionedUsers:find(function(user) return user == client.user end) and 
		not (guilds[message.guild.id].prefix and message.content:find(guilds[message.guild.id].prefix))) then
		return
	end
	
	logger:log(4, "Message received, processing...")
	if not message.guild.me:getPermissions(message.channel):has(permission.manageChannels, permission.moveMembers) then
		message:reply(guilds[message.guild.id].locale.badPermissions)
	end
	
	local command = match(message.content, "%s(%a+)")
	if not command then command = commands.help end
	local res, msg = pcall(function() if actions[command] then actions[command](message) end end)
	if not res then 
		logger:log(1, "Couldn't process the message, %s", msg)
		client:getChannel("686261668522491980"):send("Couldn't process the message: "..message.content.."\n"..msg)
		message:reply(message.author.id ~= "188731184501620736"
			and (format(guilds[message.guild.id].locale.error, os.date("%b %d %X")).."\nhttps://discord.gg/tqj6jvT")
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
		logger:log(4, member.user.id.." joined lobby "..channel.id)
		local category = channel.category or channel.guild
		local newChannel = category:createVoiceChannel((member.nickname or member.user.name).."'s channel")
		assert(newChannel, "Failed to create new channel for lobby "..channel.id)
		assert(member:setVoiceChannel(newChannel.id), "Failed to move "..member.user.id.." from "..channel.id.." to "..newChannel.id)
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
		if #channel.connectedMembers == 0 then
			assert(channel:delete(), "Failed to delete channel "..channel.id)
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
	client:getChannel("676791988518912020"):getLastMessage():setContent(os.date())
	
	for channelID,_ in pairs(channels) do
		local channel = client:getChannel(channelID)
		if channel then
			if #channel.connectedMembers == 0 then
				channel:delete()
			end
		end
	end
	
	client:setGame({name = channels:people() == 0 and "the sound of silence" or (channels:people()..(channels:people() == 1 and " person" or " people").." on "..#channels..(#channels == 1 and " channel" or " channels")), type = 2})
end))

clock:on(safeEvent('hour', function()
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