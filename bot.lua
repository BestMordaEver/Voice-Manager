local discordia = require "discordia"
local config = require "./config.lua"
local https = require "coro-http"
local json = require "json"
local conn = require "sqlite3".open("data.db")

local client = discordia.Client {routeDelay = 300}
local clock = discordia.Clock()
local logger = discordia.Logger(4, '%F %T')
local permission, channelType = discordia.enums.permission, discordia.enums.channelType

local servers
local stats = {servers = 0, lobbies = 0, channels = 0, people = 0}

local function safeEvent (name, fn)
	return name, function (...)
		local success, err = pcall(fn, ...)
		if not success then logger:log(1, "Error on "..name..": "..err) end
	end
end

local commands = {
	help = "help",
	register = "register",
	unregister = "unregister",
	list = "list",
	shutdown = "shutdown",
	stats = "stats",
	support = "support",
	id = "id"
}

servers = setmetatable({
	-- serverID = {channelID = 0 (if lobby) or 1 (if new channel)}
},{
	__index = {
		addServer = function (self, serverID)
			if not self[serverID] then 
				self[serverID] = {}
				stats.servers = stats.servers + 1
				logger:log(4, "MEMORY: Added server "..serverID)
			end
			if not conn:exec("SELECT * FROM servers WHERE id = "..serverID) then
				local res = pcall(function() conn:exec("INSERT INTO servers VALUES("..serverID..")") end)
				if res then logger:log(4, "DATABASE: Added server "..serverID) end
			end
		end,
		
		addLobby = function (self, serverID, lobbyID)
			self:addServer(serverID)
			if self[serverID][lobbyID] == 1 then self:deleteChannel(serverID, lobbyID) end	-- I swear to god, there will be one crackhead
			if self[serverID][lobbyID] ~= 0 then 
				self[serverID][lobbyID] = 0
				stats.lobbies = stats.lobbies + 1
				logger:log(4, "MEMORY: Added lobby "..lobbyID.." in "..serverID)
			end
			if not conn:exec("SELECT * FROM lobbies WHERE id = "..lobbyID) then
				local res = pcall(function() conn:exec("INSERT INTO lobbies VALUES("..lobbyID..","..serverID..")") end)
				if res then logger:log(4, "DATABASE: Added lobby "..lobbyID.." in "..serverID) end
			end
		end,
		
		addChannel = function (self, serverID, channelID)
			self:addServer(serverID)
			if self[serverID][channelID] ~= 1 then
				self[serverID][channelID] = 1
				stats.channels = stats.channels + 1
				logger:log(4, "MEMORY: Added channel "..channelID.." in "..serverID)
			end
			if not conn:exec("SELECT * FROM channels WHERE id = "..channelID) then
				local res = pcall(function() conn:exec("INSERT INTO channels VALUES("..channelID..","..serverID..")") end)
				if res then logger:log(4, "DATABASE: Added channel "..channelID.." in "..serverID) end
			end
		end,
		
		deleteServer = function (self, serverID)
			if self[serverID] then
				self[serverID] = nil
				stats.servers = stats.servers + 1
				logger:log(4, "MEMORY: Deleted server "..serverID)
			end
			if conn:exec("SELECT * FROM servers WHERE id = "..serverID) then
				local res = pcall(function() conn:exec("DELETE FROM servers WHERE id = "..serverID) end)
				if res then logger:log(4, "DATABASE: Deleted server "..serverID) end
			end
		end,
		
		deleteLobby = function (self, serverID, lobbyID)
			if self[serverID] and self[serverID][lobbyID] == 0 then 
				self[serverID][lobbyID] = nil
				stats.lobbies = stats.lobbies - 1
				logger:log(4, "MEMORY: Deleted lobby "..lobbyID..(serverID and (" in "..serverID) or ""))
			end
			if conn:exec("SELECT * FROM lobbies WHERE id = "..lobbyID) then
				local res = pcall(function() conn:exec("DELETE FROM lobbies WHERE id = "..lobbyID) end)
				if res then logger:log(4, "DATABASE: Deleted lobby "..lobbyID..(serverID and (" in "..serverID) or "")) end
			end
		end,
		
		deleteChannel = function (self, serverID, channelID)
			if self[serverID] and self[serverID][channelID] == 1 then
				self[serverID][channelID] = nil
				stats.channels = stats.channels - 1
				logger:log(4, "MEMORY: Deleted channel "..channelID..(serverID and (" in "..serverID) or ""))
			end
			if conn:exec("SELECT * FROM channels WHERE id = "..channelID) then
				local res = pcall(function() conn:exec("DELETE FROM channels WHERE id = "..channelID) end)
				if res then logger:log(4, "DATABASE: Deleted channel "..channelID..(serverID and (" in "..serverID) or "")) end
			end
		end,
		
		checkServer = function (self, serverID)
			if client:getGuild(serverID) then
				self:addServer(serverID)
				return true
			else
				self:deleteServer(serverID)
				return false
			end
		end,
		
		checkLobby = function (self, lobbyID)
			local lobby = client:getChannel(lobbyID)
			if lobby then
				self:addLobby(lobby.guild.id, lobby.id)
			else
				self:deleteLobby(nil, lobbyID)
			end
			return lobby
		end,
		
		checkChannel = function (self, channelID)
		local channel = client:getChannel(channelID)
			if channel then
				self:addChannel(channel.guild.id, channel.id)
			else
				self:deleteChannel(nil, channelID)
			end
			return lobby
		end,
		
		load = function (self)		-- used only upon startup
			logger:log(4, "Loading servers from client")
			for _, server in pairs(client.guilds) do
				self:checkServer(server.id)
			end
			
			logger:log(4, "Loading servers from save")
			local serverIDs = conn:exec("SELECT * FROM servers")
			if serverIDs then
				for _, serverID in ipairs(serverIDs[1]) do
					self:checkServer(serverID)
				end
			end
	
			logger:log(4, "Loading lobbies")
			local lobbyIDs = conn:exec("SELECT * FROM lobbies")
			if lobbyIDs then
				for _, lobbyID in ipairs(lobbyIDs[1]) do
					self:checkLobby(lobbyID)
				end
			end
			
			logger:log(4, "Loading channels")
			local channelIDs = conn:exec("SELECT * FROM channels")
			if channelIDs then
				for _, channelID in ipairs(channelIDs[1]) do
					self:checkChannel(channelID)
				end
			end
			
			logger:log(4, "Loaded")
		end
	}
})

local statservers = setmetatable({
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
	
	--["bots.ondiscord.xyz"] = {
	--	endpoint = "https://bots.ondiscord.xyz/bot-api/bots/601347755046076427/guilds",
	--	body = "guildCount"
	--},
	
	["discord.bots.gg"] = {
		endpoint = "https://discord.bots.gg/api/v1/bots/601347755046076427/stats",
		body = "guildCount"
	}
},{
	__call = function (self)
		for name, server in pairs(self) do 
			coroutine.wrap(function (name, server)
				local res, body = https.request("POST",server.endpoint,
					{{"Authorization", config.tokens[name]},{"Content-Type", "application/json"},{"Accept", "application/json"}},
					json.encode({[server.body] = stats.servers}))
				if res.code ~= 204 and res.code ~= 200 then 
					logger:log(2, "Couldn't send stats to "..name.." - "..body)
				end
			end)(name, server)
		end 
	end
})

local actions
actions = {
	[commands.help] = function (message)
		logger:log(4, "Help action invoked")
		message:reply("Ping this bot to get help message\nWrite commands after the mention, for example - `@Voice Manager register 123456789123456780`\n`"..
			commands.register.." [voice_chat_id OR voice_chat_name]` - registers a voice chat that will be used as a lobby\n`"..
			commands.unregister.." [voice_chat_id OR voice_chat_name]` - unregisters an existing lobby\n`"..
			commands.id.." [voice_chat_name OR category_name]` - use this to learn ids of voice channels by name or category\n**:arrow_up: You need a 'Manage Channels permission to use those commands! :arrow_up:**\n`"..
			commands.list.."` - lists all registered lobbies and how many new channels exist\n`"..
			commands.stats.."` - take a sneak peek on bot's performance!\n`"..
			commands.support.."` - sends an invite to support Discord server")
	end,
	
	regFilter = function (message, command)
		if not message.member:hasPermission(permission.manageChannels) then
			logger:log(4, "Mention in vain")
			message:reply(message.author.mentionString.. ', you need to have "Manage Channels" permission to do this')
			return
		end
		
		logger:log(4, command.." action invoked")
		local id = message.content:match(command.."%s+(.-)$")
		
		if not tonumber(id) and type(id) == "string" then
			id = id:lower()
			local channels = message.guild.voiceChannels:toArray("position", function (channel) return channel.name:lower() == id end)
			if #channels == 0 then
				logger:log(4, "Bad "..command.." input")
				message:reply("Couldn't find a channel by name")
				return
			elseif #channels == 1 then
				id = channels[1].id
			else
				logger:log(4, "Ambiguous "..command.." input")
				actions[commands.id](message, id)
				return
			end
		end
		
		if not id or not message.guild.voiceChannels:find(function(voiceChannel) if id == voiceChannel.id then return true end end) then 
			logger:log(4, "Bad "..command.." input")
			message:reply("You have to specify a valid voice channel id or name\nExample: `@Voice Manager "..command.." 123456789123456780`")
			return
		end
		
		return id
	end,

	[commands.register] = function (message)
		local id = actions.regFilter(message, commands.register)
		if not id then return end
		
		servers:addLobby(message.guild.id, id)
		message.channel:send("Channel `"..client:getChannel(id).name.."` is now registered as a lobby")
		logger:log(4, "Registered "..id.." successfully")
		stats.lobbies = stats.lobbies + 1
	end,

	[commands.unregister] = function (message)
		local id = actions.regFilter(message, commands.unregister)
		if not id then return end
		
		servers:deleteLobby(message.guild.id, id)
		message.channel:send("Channel `"..client:getChannel(id).name.."` was unregistered")
		logger:log(4, "Unregistered "..message.channel.id.." successfully")
		stats.lobbies = stats.lobbies - 1
	end,
	
	[commands.id] = function (message, target)
		if not message.member:hasPermission(permission.manageChannels) then
			logger:log(4, "Mention in vain")
			message:reply(message.author.mentionString.. ', you need to have "Manage Channels" permission to do this')
			return
		end
	
		logger:log(4, "ID action invoked")
		local msg = target and "There are several channels with this name\n" or ""
		target = target or message.content:match(commands.id.."%s+(.-)$")
		local categories = message.guild.categories:toArray("position")
		local channels = message.guild.voiceChannels:toArray("position", function (channel) return not channel.category end)
		
		if target then
			target = target:lower()
			for _, channel in ipairs(channels) do
				if channel.name == target then
					msg = msg.."`"..channel.name.."` -> `"..channel.id.."`\n"
				end
			end
			for _, category in ipairs(categories) do
				for _, channel in ipairs(category.voiceChannels:toArray("position")) do
					if category.name:lower() == target or channel.name:lower() == target then
						msg = msg.."`"..channel.name.."` in `"..channel.category.name.."` -> `"..channel.id.."`\n"
					end
				end
			end
		else
			for _, channel in ipairs(channels) do
				msg = msg.."`"..channel.name.."` -> `"..channel.id.."`\n"
			end
			for _, category in ipairs(categories) do
				for _, channel in ipairs(category.voiceChannels:toArray("position")) do
					msg = msg.."`"..channel.name.."` in `"..channel.category.name.."` -> `"..channel.id.."`\n"
				end
			end
		end
		
		if #msg > 2000 then
			msg = msg:sub(1,1800).."\nPhew, I can't display more than that! Try to narrow down the list with the channel name, like ```@Voice Manager id channel_name```Also, consider turning the developer mode on, it's quite useful!"
		end
		message:reply(msg)
	end,
	
	[commands.list] = function (message)
		logger:log(4, "List action invoked")
		local str = "Registered lobbies on this server:\n"
		local channels = 0
		servers:checkServer(message.guild.id)
		for channelID, type in pairs(servers[message.guild.id]) do
			if pingChannel(message.guild.id, channelID) then
				if type == 0 then
					str = str.."`"..channelID.."` -> `"..client:getChannel(channelID).name.."`\n"
				else
					channels = channels + 1
				end
			end
		end
		message.channel:send(str.."New channels on this server: **"..channels.."**")
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
		t = os.clock() - t
		logger:log(4, "Stats action invoked")
		message:reply("I'm currently on **`"..
			stats.servers..(stats.servers == 1 and "`** server serving **`" or "`** servers serving **`")..
			stats.lobbies..(stats.lobbies == 1 and "`** lobby\nThere " or "`** lobbies\nThere ")..
			(stats.channels == 1 and "is **`" or "are **`")..stats.channels..(stats.channels == 1 and "`** new channel with **`" or "`** new channels with **`")..
			stats.people..(stats.people == 1 and "`** person" or "`** people").."\nPing is **`"..t.."ms`**")
	end,
	
	[commands.support] = function (message)
		message:reply("https://discord.gg/tqj6jvT")
	end
}

client:on(safeEvent('messageCreate', function (message)
	if message.channel.type ~= channelType.text and not message.author.bot then
		message:reply("This bot can only be used in servers. Mention the bot within the server to get the help message.")
		return
	end
	
	if not message.mentionedUsers:find(function(user) return user == client.user end) or message.author.bot then
		return
	end
	
	logger:log(4, "Message received, processing...")
	if not message.guild.me:getPermissions(message.channel):has(permission.manageChannels, permission.moveMembers) then
		message:reply('This bot needs "Manage Channels" and "Move Members" permissions to function!')
	end
	
	local command = message.content:match("%s(%a+)")
	if not command then command = commands.help end
	local res, msg = pcall(function() if actions[command] then actions[command](message) end end)
	if not res then logger:log(1, "Couldn't process the message, "..msg) end
end))

client:on(safeEvent('guildCreate', function (guild)
	servers:addServer(guild.id)
	client:getChannel("676432067566895111"):send(guild.name.." added me!\n")
end))

client:on(safeEvent('guildDelete', function (guild)
	servers:deleteServer(guild.id)
	client:getChannel("676432067566895111"):send(guild.name.." removed me!\n")
end))

client:on(safeEvent('voiceChannelJoin', function (member, channel)
	if not servers:checkServer(channel.guild.id) then return end
	if servers[channel.guild.id][channel.id] == 0 then
		logger:log(4, member.user.id.." joined lobby "..channel.id)
		local category = channel.category or channel.guild
		local newChannel = category:createVoiceChannel((member.nickname or member.user.name).."'s channel")
		member:setVoiceChannel(newChannel.id)
		logger:log(4, "Created "..newChannel.id)
		servers:addChannel(channel.guild.id, newChannel.id)
		newChannel:setUserLimit(channel.userLimit)
		if channel.guild.me:getPermissions(channel):has(permission.manageRoles, permission.manageChannels, permission.muteMembers, permission.deafenMembers, permission.moveMembers) then
			newChannel:getPermissionOverwriteFor(member):allowPermissions(permission.manageChannels, permission.muteMembers, permission.deafenMembers, permission.moveMembers)
		end
	end
end))

client:on(safeEvent('voiceChannelLeave', function (member, channel)
	if not servers:checkServer(channel.guild.id) then return end
	if servers[channel.guild.id][channel.id] == 1 and #channel.connectedMembers == 0 then
		--servers:deleteChannel(channel.guild.id, channel.id) -- cleanup happens in channelDelete event
		channel:delete()
		logger:log(4, "Deleted "..channel.id)
	end
end))

client:on(safeEvent('channelDelete', function (channel)
	servers:deleteLobby(channel.guild.id, channel.id)
	servers:deleteChannel(channel.guild.id, channel.id)
end))

client:on(safeEvent('ready', function()
	servers:load()
	clock:start()
	client:getChannel("676432067566895111"):send("I'm listening")
end))

clock:on(safeEvent('min', function()
	local people, channels = 0, 0
	for serverID, server in pairs(servers) do
		for channelID, type in pairs(server) do
			local channel = client:getChannel(channelID)
			if channel and type == 1 then
				if #channel.connectedMembers ~= 0 then
					channels = channels + 1
					people = people + #channel.connectedMembers
				else
					channel:delete()
				end
			end
		end
	end
	client:setGame({name = people == 0 and "the sound of silence" or (people..(people == 1 and " person" or " people").." on "..channels..(channels == 1 and " channel" or " channels")), type = 2})
	stats.channels = channels
	stats.people = people
	client:getChannel("676791988518912020"):getLastMessage():delete()
	client:getChannel("676791988518912020"):send("beep boop beep")
	statservers()
end))

client:on(safeEvent('shutdown', actions[commands.shutdown]))

local sd = function () client:emit("shutdown") end -- ensures graceful shutdown

process:on('sigterm', sd)
process:on('sigint', sd)

client:run('Bot '..config.token)