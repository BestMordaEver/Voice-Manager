local discordia = require "discordia"
local client, logger = discordia.storage.client, discordia.storage.logger
local locale = require "./locale.lua"
local utils = require "./utils.lua"

local channels = require "./channels.lua"
local lobbies = require "./lobbies.lua"
local guilds = require "./guilds.lua"
local embeds = require "./embeds.lua"

local discordia = require "discordia"
discordia.extensions.table()
local permission, channelType = discordia.enums.permission, discordia.enums.channelType

local truePositionSorting, getLocale = utils.truePositionSorting, utils.getLocale

local function parseForIDs (message, command)			-- returns a table of all ids
	logger:log(4, command.." action invoked")
	local id = message.content:match(command.."%s+(.-)$")
	if not id then
		logger:log(4, "Empty input")
		if not message.guild or not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
			message:reply(message.guild and getLocale(message.guild).gimmeReaction or ("This would work in server, but in DMs you have to include the ID of the channel that you want to "..command))
			return
		end
		
		local ids = {}
		for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel)
			return (command == "register") == not lobbies[channel.id] and		-- embeds never offer invalid channels
				message.guild.me:hasPermission(channel.category, permission.manageChannels) and
				message.member:hasPermission(channel, permission.manageChannels)	-- non-embed related permission checks are in regunregAction
		end), truePositionSorting)) do
			table.insert(ids, channel.id)
		end
		embeds:send(message, command, ids)
		return
	end
	
	local ids = {}
	for ID in id:gmatch("%d+") do
		if client:getChannel(ID) then
			table.insert(ids, ID)
		end
	end
	
	if #ids == 0 then
		if not message.guild then
			logger:log(4, command.." by name in dm")
			message:reply("I can "..command.." by name only in server")
			return
		end
		
		id = id:lower()
		for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) 
			return channel.name:lower() == id
		end), truePositionSorting)) do
			table.insert(ids, channel.id)
		end
		
		
		if #ids == 0 then
			logger:log(4, "Bad "..command.." input")
			message:reply(getLocale(message.guild).badInput)
			return
		elseif #ids == 1 then
			return ids
		else
			local redundant, count = {}, #ids
			
			for i, _ in ipairs(ids) do repeat
				local channel = client:getChannel(ids[i])
				if not ((command == "register") == not lobbies[channel.id] and
					message.guild.me:hasPermission(channel.category, permission.manageChannels) and
					message.member:hasPermission(channel, permission.manageChannels)) then
					
					table.insert(redundant, table.remove(ids, i))
				else
					break
				end
			until not ids[i] end
			
			if #ids == 1 then return ids end
			if #redundant == count then return redundant end
			
			logger:log(4, "Ambiguous "..command.." input")
			
			message:reply(getLocale(message.guild).ambiguousID)
			if not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
				message:reply(getLocale(message.guild).gimmeReaction)
				return
			end

			embeds:send(message, command, ids)
			return
		end
	else
		return ids
	end
end

local function regunregAction (message, ids, action)	-- register and unregister are painfully simmilar, unified here
	local badUser, badBot, badChannel, redundant = {}, {}, {}, {}
	local locale = getLocale(message.guild)
	
	for i,_ in ipairs(ids) do repeat
		local channel = client:getChannel(ids[i])
		if channel.type == channelType.voice then
			if (action == "register") == not lobbies[channel.id] then
				if channel.guild:getMember(message.author):hasPermission(channel, permission.manageChannels) then
					if action == "register" and not channel.guild.me:hasPermission(channel.category, permission.manageChannels) then
						table.insert(badBot, table.remove(ids, i))
					else
						break
					end
				else
					table.insert(badUser, table.remove(ids, i))
				end
			else
				table.insert(redundant, table.remove(ids, i))
			end
		else
			table.insert(badChannel, table.remove(ids, i))
		end
	until not ids[i] end

	local msg = ""
	if #ids > 0 then
		msg = string.format(#ids == 1 and (action == "register" and locale.registeredOne or locale.unregisteredOne) or (action == "register" and locale.registeredMany or locale.unregisteredMany), #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
			if action == "register" then
				lobbies:add(channelID)
			else
				lobbies:remove(channelID)
			end
		end
	end
	
	if #badChannel > 0 then
		msg = msg..(#badChannel == 1 and locale.badChannel or locale.badChannels).."\n"
		for _, channelID in ipairs(badChannel) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
		end
	end
	
	if #redundant > 0 then
		msg = msg..(action == "register" and (#redundant == 1 and locale.redundantRegister or locale.redundantRegisters) or 
			(#redundant == 1 and locale.redundantUnregister or locale.redundantUnregisters)).."\n"
		for _, channelID in ipairs(redundant) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
		end
	end

	if #badBot > 0 then
		msg = msg..(#badBot == 1 and locale.badBotPermission or locale.badBotPermissions).."\n"
		for _, channelID in ipairs(badBot) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
		end
	end

	if #badUser > 0 then
		msg = msg..(action == "register" and (#badUser == 1 and locale.badUserPermissionRegister or locale.badUserPermissionsRegister) or 
			(#badUser == 1 and locale.badUserPermissionUnregister or locale.badUserPermissionsUnregister)).."\n"
		for _, channelID in ipairs(badUser) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
		end
	end
	
	return msg
end

return {
	help = function (message)
		logger:log(4, "Help action invoked")
		message:reply(getLocale(message.guild).helpText)
	end,
	
	register = function (message, id)
		local ids
		
		if id then -- sent by embed
			ids = {id}
		else
			ids = parseForIDs(message, "register")
			if not ids then return end
		end
		
		message:reply(regunregAction(message, ids, "register"))
	end,

	unregister = function (message, id)
		local ids
		
		if id then -- sent by embed
			ids = {id}
		else
			ids = parseForIDs(message, "unregister")
			if not ids then return end
		end
		
		message:reply(regunregAction(message, ids, "unregister"))
	end,
	
	template = function (message)
		logger:log(4, "Template action invoked")
		
		local template, scope = content:match("^.-template%s*\"(.-)\"%s*\"(.-)\"$")
	end,
	
	language = function (message)
		if not message.guild then
			logger:log(4, "Language in dm")
			message:reply("I can process that only in server")
			return
		end
		
		if not message.member:hasPermission(permission.manageChannels) then
			logger:log(4, "Mention in vain")
			message:reply(getLocale(message.guild).mentionInVain:format(message.author.mentionString))
			return
		end
		
		logger:log(4, "Language action invoked")
		
		local lang = (message.content:match("language%s+(.-)$") or ""):lower()
		
		if locale[lang] then
			guilds:updateLocale(message.guild.id, lang)
			message:reply(getLocale(message.guild).updatedLocale)
		else
			logger:log(4, "No language '%s' found", lang)
			local msg = getLocale(message.guild).availableLanguages
			for langName, _ in pairs(locale) do
				msg = msg.." "..langName..","
			end
			msg = msg:sub(1,-2)
			message:reply(msg)
		end
	end,
	
	prefix = function (message)
		if not message.guild then
			logger:log(4, "Prefix in dm")
			message:reply("I can process that only in server")
			return
		end
		
		logger:log(4, "Prefix action invoked")
		local prefix = message.guild and guilds[message.guild.id].prefix or nil
		local newPrefix = 
			message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(.-)$") or 
			message.content:match("^<@.?601347755046076427>%s*prefix%s*(.-)$") or 
			message.content:match("^<@.?676787135650463764>%s*prefix%s*(.-)$")
		
		if newPrefix then
			if not message.member:hasPermission(permission.manageChannels) then
				message:reply(getLocale(message.guild).mentionInVain:format(message.author.mentionString))
				return
			end
			guilds:updatePrefix(message.guild.id, newPrefix)
			message:reply(getLocale(message.guild).prefixConfirm:format(newPrefix))
		else
			message:reply(string.format(guilds[message.guild.id].newPrefix and getLocale(message.guild).prefixThis or getLocale(message.guild).prefixAbsent, guilds[message.guild.id].Prefix))
		end
	end,
	
	list = function (message)
		if not message.guild then
			logger:log(4, "List in dm")
			message:reply("I can process that only in server")
			return
		end
		
		logger:log(4, "List action invoked")
		
		local locale = getLocale(message.guild)
		local lobbies = message.guild.voiceChannels:toArray(function (channel) return lobbies[channel.id] end)
		table.sort(lobbies, truePositionSorting)
		
		local msg = (#lobbies == 0 and locale.noLobbies or locale.someLobbies) .. "\n"
		for _,channel in ipairs(lobbies) do
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
		end
		
		message:reply(msg)
	end,
	
	shutdown = function (message)
		if message then
			if message.author.id ~= "188731184501620736" then return end
			message:reply("Shutting down gracefully")
			logger:log(4, "Shutdown action invoked")
		end
		
		local status, msg = pcall(function()
			client:setGame({name = "the maintenance", type = 3})
			clock:stop()
			client:stop()
			--conn:close()
		end)
		logger:log(3, (status and "Shutdown successfull" or ("Couldn't shutdown gracefully, "..msg)))
		process:exit()
	end,
	
	stats = function (message)
		logger:log(4, "Stats action invoked")
		local locale = getLocale(message.guild)
		
		local t = os.clock()
		message.channel:broadcastTyping()
		t = math.modf((os.clock() - t)*1000)
		
		local guildCount, lobbyCount, channelCount, peopleCount = #client.guilds, #lobbies, #channels, channels:people()
		message:reply(string.format(
			(guildCount == 1 and lobbyCount == 1) and locale.serverLobby or (
			guildCount == 1 and locale.serverLobbies or (
			lobbyCount == 1 and locale.serversLobby or 
			locale.serversLobbies)), guildCount, lobbyCount) .. "\n" ..
		string.format(
			(channelCount == 1 and peopleCount == 1) and locale.channelPerson or (
			channelCount == 1 and locale.channelPeople or (
			peopleCount == 1 and locale.channelsPerson or -- practically impossible, but whatever
			locale.channelsPeople)), channelCount, peopleCount) .. "\n" ..
		string.format(locale.ping, t))
	end,
	
	support = function (message)
		logger:log(4, "Support action invoked")
		message:reply("https://discord.gg/tqj6jvT")
	end
}
