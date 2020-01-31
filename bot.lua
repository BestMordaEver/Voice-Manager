local discordia = require "../deps/discordia/init.lua"
local config = require "./config.lua"

local client = discordia.Client {routeDelay = 100}
local DBL = discordia.DBLAPI(config.dbltoken, client)
local clock = discordia.Clock()
local logger = discordia.Logger(4, '%F %T')
local serversMutex, channelsMutex = discordia.Mutex(), discordia.Mutex()
local permission, channelType = discordia.enums.permission, discordia.enums.channelType

local verboseGuilds = true
local servers

local sandbox = setmetatable({ }, { __index = _G })

local commands = {
	help = "help",
	register = "register",
	unregister = "unregister",
	list = "list",
	shutdown = "shutdown",
	verbose = "verbose",
	execute = "execute"
}

local pingServer = function (serverID)
	if client:getGuild(serverID) then 
		if not servers[serverID] then servers[serverID] = {} end
		return true
	elseif servers[serverID] then
		servers[serverID] = nil
	end
end

local pingChannel = function (serverID, channelID)
	if pingServer(serverID) then
		if client:getChannel(channelID) then
			return true
		elseif servers[serverID][channelID] then
			servers[serverID][channelID] = nil
		end
	end
end

servers = setmetatable({
	-- serverID = {channelID = 0 (if main lobby) or 1 (if new lobby)}
},{__index = {
	load = function (self)		-- used only upon startup
		for _, guild in pairs(client.guilds) do self[guild.id] = {} end
		serversMutex:lock()
		logger:log(3, "Loading servers file")
		local serverCount, channelCount = 0,0
		local file, err = io.open(config.saveServers,"r")
		if file then
			logger:log(4, "Found servers save file, reading...")
			for line in file:read("*all"):gmatch("(.-)\n") do
				local serverID = line:match("%d+")
				if client:getGuild(serverID) then
					serverCount = serverCount + 1
					self[serverID] = {}
					local server = self[serverID]
					for channelID in line:gmatch("%s(%d+)") do
						if client:getChannel(channelID) then
							channelCount = channelCount + 1
							server[channelID] = 0
						end
					end
				else
					logger:log(2, "No servers info found")
				end
			end
			file:close()
			logger:log(4, "Done with servers save file, found %s servers and %s bound channels", serverCount, channelCount)
		else
			logger:log(1, "Couldn't open the servers file, %s", err)
		end
		serversMutex:unlock()
		
		serverCount, channelCount = 0,0
		channelsMutex:lock()
		logger:log(3, "Loading channels file")
		file, err = io.open(config.saveChannels,"r")
		if file then
			logger:log(4, "Found channels save file, reading...")
			for line in file:read("*all"):gmatch("(.-)\n") do
				local serverID = line:match("%d+")
				if client:getGuild(serverID) then
					serverCount = serverCount + 1
					if not self[serverID] then self[serverID] = {} end
					local server = self[serverID]
					for channelID in line:gmatch("%s(%d+)") do
						if client:getChannel(channelID) then
							channelCount = channelCount + 1
							server[channelID] = 1
						end
					end
				else
					logger:log(2, "No channels info found")
				end
			end
			file:close()
			logger:log(4, "Done with channels save file, found %s servers and %s new channels", serverCount, channelCount)
		else
			logger:log(1, "Couldn't open the channels file, %s", err)
		end
		channelsMutex:unlock()
	end,

	saveServers = function (self)
		local serverCount, channelCount = 0,0
		serversMutex:lock()
		logger:log(3, "Updating servers file")
		local file, err = io.open(config.saveServers,"w")
		if file then
			logger:log(4, "Found servers save file, writing...")
			for serverID, server in pairs(self) do
				if pingServer(serverID) then
					serverCount = serverCount + 1
					file:write(serverID)
					for channelID, type in pairs(server) do
						if pingChannel(serverID, channelID) then
							if type == 0 then
								file:write(" ",channelID)
								channelCount = channelCount + 1
							end
						end
					end
					file:write("\n")
				end
			end
			file:close()
			logger:log(4, "Done with servers save file, wrote %s servers and %s bound channels", serverCount, channelCount)
		else
			logger:log(1, "Couldn't open the servers file, %s", err)
		end
		serversMutex:unlock()
	end,
	
	saveChannels = function (self)
		local serverCount, channelCount = 0,0
		channelsMutex:lock()
		logger:log(3, "Updating channels file")
		local file, err = io.open(config.saveChannels,"w")
		if file then
			logger:log(4, "Found channels save file, writing...")
			for serverID, server in pairs(self) do
				if pingServer(serverID) then
					serverCount = serverCount + 1
					file:write(serverID)
					for channelID, type in pairs(server) do
						if pingChannel(serverID, channelID) then
							if type == 1 then 
								file:write(" ",channelID) 
								channelCount = channelCount + 1
							end
						end
					end
					file:write("\n")
				end
			end
			file:close()
			logger:log(4, "Done with channels save file, wrote %s servers and %s new channels", serverCount, channelCount)
		else
			logger:log(1, "Couldn't open the channels file, %s", err)
		end
		channelsMutex:unlock()
	end}
})

local shutdown = function ()
	logger:log(3, "Starting the shutdown")
	local status, msg = pcall(function()
		clock:stop()
		client:stop()
	end)
	logger:log(3, (status and "Shutdown successfull, saving data..." or "Couldn't shutdown gracefully, %s"), msg)
	servers:saveServers()
	servers:saveChannels()
	if not status then process:kill() end
end

local function code(str)
    return string.format('```\n%s```', str)
end

local actions = {
	[""] = function (message)
		message.channel:broadcastTyping()
		logger:log(4, "Help action invoked")
		message:reply([[Ping this bot to get help message
Write commands after the mention, for example - `@Voice Manager register 123456789123456780`
**================**
`register [voice_chat_id]` - registers a voice chat, which will be used as a lobby
`unregister [voice_chat_id]` - unregisters a voice chat
`list` - lists all registered lobbies and how many new channels exist]])
	end,

	[commands.register] = function (message)
		message.channel:broadcastTyping()
		logger:log(4, "Register action invoked")
		local id = message.content:match(commands.register.."%s*(%d+)")
		if id and message.guild.voiceChannels:find(function(voiceChannel) if id == voiceChannel.id then return true end end) then
			servers[message.guild.id][id] = 0
			servers:saveServers()
			message.channel:send("Channel `"..client:getChannel(id).name.."` is now registered as a lobby")
			logger:log(4, "Registered successfully")
		else
			logger:log(4, "Bad registration input")
			message:reply([[You have to specify a valid voice channel id
**================**
Example: `@Voice Manager register 123456789123456780`]])
		end
	end,

	[commands.unregister] = function (message)
		message.channel:broadcastTyping()
		logger:log(4, "Unregister action invoked")
		local id = message.content:match(commands.unregister.."%s*(%d+)")
		if id and servers[message.guild.id][id] then
			servers[message.guild.id][id] = nil
			servers:saveServers()
			message.channel:send("Channel `"..client:getChannel(id).name.."` was unregistered")
			logger:log(4, "Unregistered successfully")
		else
			logger:log(4, "Bad unregistration input")
			message:reply([[You have to specify a valid voice channel id
**================**
Example: `@Voice Manager unregister 123456789123456780`]])
		end
	end,
	
	[commands.list] = function (message)
		message.channel:broadcastTyping()
		logger:log(4, "List action invoked")
		local str = "Registered lobbies on this server:\n"
		local channels = 0
		if not servers[message.guild.id] then servers[message.guild.id] = {} end
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
		if message.author.id ~= "188731184501620736" then return end
		logger:log(4, "Shutdown action invoked")
		message:reply("Shutting down gracefully")
		shutdown()
	end,
	
	[commands.verbose] = function (message)
		if message.author.id ~= "188731184501620736" then return end
		logger:log(4, "Verbose switch action invoked")
		local status = message.content:match(commands.verbose.."%s*(%a+)")
		if status == "true" or status == "on" or status == "enable" then
			verboseGuilds = true
			logger:log(3, "Set guild updates to verbose")
		elseif status == "false" or status == "off" or status == "disable" then
			verboseGuilds = false
			logger:log(3, "Set guild updates to silent")
		else logger:log(4, "Bad verbose switch input") end
	end,
	
	[commands.execute] = function (message)
		if message.author.id ~= "188731184501620736" then return end
		logger:log(4, "Execute action invoked")
		local codeblock = message.content:match("execute(.*)")
		
		sandbox.print = function(content)
			message:reply(tostring(content))
		end
		
		sandbox.client = client
		sandbox.servers = servers

		local fn, syntaxError = load(codeblock, 'DiscordBot', 't', sandbox)
		if not fn then 
			logger:log(1, "Couldn't load chunk, %s", syntaxError)
			return message:reply(code(syntaxError))
		end

		local success, runtimeError = pcall(fn)
		if not success then
			logger:log(1, "Runtime error, %s", runtimeErrorError)
			return message:reply(code(runtimeError))
		end
	end
}

client:on('messageCreate', function (message)
	if message.channel.type ~= channelType.text or message.author.bot or
		not message.member:hasPermission(permission.manageChannels) or
		not message.mentionedUsers:find(function(user) if user == client.user then return true end end)
	then return end

	logger:log(4, "Message received, processing...")
	if not servers[message.guild.id] then servers[message.guild.id] = {} end
	local command = message.content:match("%s(%a+)")
	if not command or command == "help" then command = "" end
	local res, msg = pcall(function() if actions[command] then actions[command](message) end end)
	if not res then logger:log(1, "Couldn't process the message, %s", msg) end
end)

client:on('guildCreate', function (guild)
	servers[guild.id] = {}
	if verboseGuilds then client:getUser("188731184501620736"):send(guild.name.." added me!\n"..(guild.vanityCode or "No invite link available...")) end
	servers:saveServers()
	--print(pcall(function() DBL:postStats() end))
end)

client:on('guildDelete', function (guild)
	servers[guild.id] = nil
	if verboseGuilds then client:getUser("188731184501620736"):send(guild.name.." removed me!\n"..(guild.vanityCode or "No invite link available...")) end
	--print(pcall(function() DBL:postStats() end))
end)

client:on('voiceChannelJoin', function (member, channel)
	if not servers[channel.guild.id] then servers[channel.guild.id] = {}; return end
	if servers[channel.guild.id][channel.id] == 0 then
		logger:log(4, "%s joined lobby %s", member.user.id, channel.id)
		local category = channel.category or channel.guild
		local newChannel = category:createVoiceChannel((member.nickname or member.user.name).."'s Lobby")
		member:setVoiceChannel(newChannel.id)
		logger:log(4, "Created new channel %s", newChannel.id)
		servers[channel.guild.id][newChannel.id] = 1
		newChannel:setUserLimit(channel.userLimit)
	end
end)

client:on('voiceChannelLeave', function (member, channel)
	if not servers[channel.guild.id] then servers[channel.guild.id] = {}; return end
	if servers[channel.guild.id][channel.id] == 1 and #channel.connectedMembers == 0 then
		servers[channel.guild.id][channel.id] = nil
		channel:delete()
		logger:log(4, "Deleted %s", channel.id)
	end
end)

client:on('channelDelete', function(channel)
	pingChannel(channel.guild.id, channel.id)
end)

client:on('ready', function()
	servers:load()
	--print(pcall(function() DBL:postStats() end))
	clock:start()
	client:getUser("188731184501620736"):send("I'm listening")
end)

clock:on('min', function()
	servers:saveChannels()
	local people, channels = 0, 0
	for serverID, server in pairs(servers) do
		for channelID, type in pairs(server) do
			if pingChannel(serverID, channelID) then
				if type == 1 then
					local channel = client:getChannel(channelID)
					if #channel.connectedMembers ~= 0 then
						channels = channels + 1
						people = people + #channel.connectedMembers
					else
						channel:delete()
						server[channelID] = nil
					end
				end
			end
		end
	end
	client:setGame({name = people == 0 and "the sound of silence" or (people.." people on "..channels.." channels"), type = 2})
end)

client:run('Bot '..config.token)