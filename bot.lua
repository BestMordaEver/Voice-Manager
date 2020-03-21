local discordia = require "discordia"
local config = require "./config.lua"
local https = require "coro-http"
local json = require "json"
local conn = require "sqlite3".open("data.db")
local locale = require "locale.lua"

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

local channels, lobbies
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
	}
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

local actions
actions = {
	regFilter = function (message, command) -- returns a table of all ids
		if not message.member:hasPermission(permission.manageChannels) then
			logger:log(4, "Mention in vain")
			message:reply(string.format('%s, you need to have "Manage Channels" permission to do this', message.author.mentionString))
			return
		end
		
		logger:log(4, command.." action invoked")
		local id = message.content:match(command.."%s+(.-)$")
		if not id then
			logger:log(4, "Empty input")
			message:reply("Need an ID or channel name to process that!")
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
				message:reply("Couldn't find a specified channel")
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
		message:reply("Ping this bot to get help message\nWrite commands after the mention, for example - `@Voice Manager register 123456789123456780`\n**:arrow_down: You need a 'Manage Channels permission to use those commands! :arrow_down:**\n`"..
			commands.register.." [voice_chat_id OR voice_chat_name]` - registers a voice chat that will be used as a lobby. You can list several channel IDs\n`"..
			commands.unregister.." [voice_chat_id OR voice_chat_name]` - unregisters an existing lobby. You can list several channel IDs\n`"..
			commands.id.." [voice_chat_name OR category_name]` - use this to learn ids of voice channels by name or category\n**:arrow_up: You need a 'Manage Channels permission to use those commands! :arrow_up:**\n`"..
			commands.list.."` - lists all registered lobbies on the server\n`"..
			commands.stats.."` - take a sneak peek on bot's performance!\n`"..
			commands.support.."` - sends an invite to support Discord server")
	end,
	
	[commands.register] = function (message)
		local ids = actions.regFilter(message, commands.register)
		if not ids then return end
		
		local msg = string.format(#ids == 1 and ("Registered new lobby:") or ("Registered %d new lobbies:"), #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and "`%s` -> `%s` in `%s`" or "`%s` -> `%s`", channel.id, channel.name, channel.category.name).."\n"
			lobbies:add(channelID)
		end
		message:reply(msg)
		logger:log(4, "Registered "..table.concat(ids, " ").." successfully")
	end,

	[commands.unregister] = function (message)
		local ids = actions.regFilter(message, commands.unregister)
		if not ids then return end
		
		local msg = string.format(#ids == 1 and ("Unregistered new lobby:") or ("Unregistered %d new lobbies:"), #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and "`%s` -> `%s` in `%s`" or "`%s` -> `%s`", channel.id, channel.name, channel.category.name).."\n"
			lobbies:remove(channelID)
		end
		message:reply(msg)
		logger:log(4, "Unregistered "..table.concat(ids, " ").." successfully")
	end,
	
	[commands.id] = function (message, target)
		if not message.member:hasPermission(permission.manageChannels) then
			logger:log(4, "Mention in vain")
			message:reply(message.author.mentionString.. ', you need to have "Manage Channels" permission to do this')
			return
		end
	
		logger:log(4, "ID action invoked")
		local msg = target and ("There are several channels with this name".."\n") or ""
		target = target or message.content:match(commands.id.."%s+(.-)$")
		
		local channels = message.guild.voiceChannels:toArray()
		table.sort(channels, function (a, b)
			return (not a.category and b.category) or
				(a.category and b.category and a.category.position < b.category.position) or
				(a.category == b.category and a.position < b.position)
			end)
		
		for _, channel in ipairs(channels) do
			if target and (channel.name:lower() == target or (channel.category and channel.name:lower() == target)) or not target then
				msg = msg..string.format(channel.category and "`%s` -> `%s` in `%s`" or "`%s` -> `%s`", channel.id, channel.name, channel.category.name).."\n"
			end
		end
		
		if #msg > 2000 then	-- nice
			msg = msg:sub(1,1949).."\n".."Can't display more than that!"
		end
		message:reply(msg)
	end,
	
	[commands.list] = function (message)
		logger:log(4, "List action invoked")
		local lobbies = message.guild.voiceChannels:toArray("position", function (channel) return lobbies[channel.id] end)
		local msg = (#lobbies == 0 and "No lobbies registered yet!" or "Registered lobbies on this server:") .. "\n"
		for _,channel in ipairs(lobbies) do
			msg = msg..string.format(channel.category and "`%s` -> `%s` in `%s`" or "`%s` -> `%s`", channel.id, channel.name, channel.category.name).."\n"
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
			(#client.guilds == 1 and stats.lobbies == 1) and "I'm currently on **`%d`** server serving **`%d`** lobby" or (
			#client.guilds == 1 and "I'm currently on **`%d`** server serving **`%d`** lobbies" or (
			stats.lobbies == 1 and "I'm currently on **`%d`** servers serving **`%d`** lobby" or 
			"I'm currently on **`%d`** servers serving **`%d`** lobbies")), #client.guilds, stats.lobbies) .. "\n" ..
		string.format(
			(stats.channels == 1 and stats.people == 1) and "There is **`%d`** new channel with **`%d`** person" or (
			stats.channels == 1 and "There is **`%d`** new channel with **`%d`** people" or (
			stats.people == 1 and "There are **`%d`** new channels with **`%d`** person" or -- practically impossible, but whatever
			"There are **`%d`** new channels with **`%d`** people")), stats.channels, stats.people) .. "\n" ..
		string.format("Ping is **`%d ms`**", t))
	end,
	
	[commands.support] = function (message)
		logger:log(4, "Support action invoked")
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
	if not res then 
		logger:log(1, "Couldn't process the message, "..msg)
		message:reply(message.author.id ~= "188731184501620736"
			and (string.format("Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s", os.date("%b %d %X")).."\nhttps://discord.gg/tqj6jvT")
			or "You done goofed")
		client:getChannel("686261668522491980"):send("Couldn't process the message: "..message.content.."\n"..msg)
	end
end))

client:on(safeEvent('guildCreate', function (guild)
	logger:log(4, "%s", "Guild "..guild.id.." added")
	client:getChannel("676432067566895111"):send(guild.name.." added me!\n")
end))

client:on(safeEvent('guildDelete', function (guild)
	for _,channel in pairs(guild.voiceChannels) do 
		if channels[channel.id] then channels:remove(channel.id) end 
	end
	logger:log(4, "%s", "Guild "..guild.id.." removed")
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