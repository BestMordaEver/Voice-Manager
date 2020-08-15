-- all command processing happens here 

local discordia = require "discordia"
local client, logger, clock = discordia.storage.client, discordia.storage.logger, discordia.storage.clock

local channels = require "./channels.lua"
local lobbies = require "./lobbies.lua"
local guilds = require "./guilds.lua"
local embeds = require "./embeds.lua"
local locale = require "./locale"

local discordia = require "discordia"
discordia.extensions.table() -- a couple of neato functions
local permission = discordia.enums.permission

local truePositionSorting = require "./utils.lua".truePositionSorting

-- returns a messsage that can be sent to user, and a table of ids that couldn't be processed for any reason
local actionFinalizer = require "./finalizers/init.lua"

-- returns a table with IDs parsed from line and a boolean if there are several channels with given name (if given)
-- line may be a bunch of channel IDs or a channel name
local function getIDs (guild, line)
	local ids = {}
	if line then
		line = line:lower()
	
		if guild then
			for _, channel in pairs(guild.voiceChannels) do
				if channel.name:lower() == line then
					table.insert(ids, channel.id)
				end
			end
		end
		
		if #ids > 2 then
			return ids, true
		elseif #ids == 0 then
			for id in line:gmatch("%d+") do
				if client:getChannel(id) then table.insert(ids,id) end
			end
		end
	end
	return ids
end

local function registerParse (message, command) -- register unregister action pre-processing
	local ids, nameDuplicates = getIDs(message.guild, message.content:match(command.."%s+(.-)$"))
	if not ids[1] then
		if not message.guild then
			message:reply(locale.noID)
			return "Empty input"
		elseif not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
			message:reply(locale.gimmeReaction)
			return "Empty input, can't do embed"
		end
		
		local ids = {}
		for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel)
			return (command == "register") == not lobbies[channel.id] and		-- embeds never offer redundant channels
				message.guild.me:hasPermission(channel.category, permission.manageChannels) and
				message.member:hasPermission(channel, permission.manageChannels)	-- non-embed related permission checks are in actionFinalizer
		end), truePositionSorting)) do
			table.insert(ids, channel.id)
		end
		
		local newMessage = embeds:send(message, command, ids)
		if newMessage then
			return "Empty input, sent embed ".. newMessage.id
		else
			return "Couldn't send an embed"
		end
	end
	
	if #ids == 0 then
		message:reply(locale.badInput)
		return "Didn't find the channel"
	elseif nameDuplicates then
		local redundant, count = {}, #ids
		
		for i, _ in ipairs(ids) do repeat	-- clear out invalid channels
			local channel = client:getChannel(ids[i])
			if not ((command == "register") == not lobbies[channel.id] and
				message.guild.me:hasPermission(channel.category, permission.manageChannels) and
				message.member:hasPermission(channel, permission.manageChannels)) then
				
				table.insert(redundant, table.remove(ids, i))
			else
				break
			end
		until not ids[i] end
		
		if #ids == 1 then return ids end -- if only one still valid - proceed
		if #redundant == count then return redundant end -- if all are invalid - proceed for finalizer output
		
		if not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
			message:reply(locale.ambiguousID.."\n"..locale.gimmeReaction)
			return "Ambiguous input, can't do embed"
		end
		
		local newMessage = embeds:send(message, command, ids)
		if newMessage then 
			newMessage:setContent(locale.ambiguousID)
			return "Ambiguous input, sent embed "..newMessage.id
		else
			return "Couldn't send an embed"
		end
	else
		return ids
	end
end

local function complexParse (message, command) -- template target action pre-processing
	local reset, scope, argument = message.content:match('^.-'..command..'%s*(.-)%s*"(.-)"%s*(.-)$')
	
	if scope then
		local ids, duplicateNames
		if command == "template" and scope == "global" and message.guild then 
			ids = {[1] = message.guild.id}
		else 
			ids, duplicateNames = getIDs(message.guild, scope)
		end
		
		if #ids > 1 and duplicateNames then 
			message:reply(locale.ambiguousID)
			return "Ambiguous input"
		end
		
		if reset == "" and argument == "" then
			if client:getGuild(ids[1]) then
				message:reply(guilds[ids[1]].template and locale.globalTemplate:format(guilds[ids[1]].template) or locale.defaultTemplate)
				return "Sent global template"
			elseif client:getChannel(ids[1]) then
				message:reply(command == "template" and
					(lobbies[ids[1]].template and locale.lobbyTemplate:format(client:getChannel(ids[1]).name, lobbies[ids[1]].template) or locale.noTemplate)
					or
					(lobbies[ids[1]].target and locale.lobbyTarget:format(client:getChannel(ids[1]).name, lobbies[ids[1]].target) or locale.noTarget))
				return "Sent channel "..command
			else
				message:reply(locale.badInput)
				return "Didn't find the channel"
			end
		elseif #ids == 0 then
			message:reply(locale.badInput)
			return "Didn't find the channel"
		elseif reset == "reset" then
			return ids
		elseif argument ~= "" then
			return ids, argument
		end
	else
		argument = message.content:match("^.-"..command.."%s*(.-)%s*$")
		if message.guild then
			if command == "template" and argument == "" then
				message:reply(guilds[message.guild.id].template and locale.globalTemplate:format(guilds[message.guild.id].template) or locale.defaultTemplate)
				return "Sent global template"
			else
				if not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
					message:reply(locale.gimmeReaction)
					return "Empty template, can't do embed"
				end
				
				local ids = {}
				for _, channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) return lobbies[channel.id] end), truePositionSorting)) do
					table.insert(ids, channel.id)
				end
				if argument == "reset" then argument = "" end
				
				local newMessage = embeds:send(message, command..argument, ids)
				if newMessage then
					return "Empty "..command..", sent embed ".. newMessage.id
				else
					return "Couldn't send an embed"
				end
			end
		else
			message:reply(locale.noID)
			return "Empty "..command.." in dm"
		end
	end
end

-- all possible bot commands are processed here, should return message for logger
return {
	help = function (message)
		local command = (message.content:match("help%s*(.-)$") or "help"):lower()
		if not (command and locale[command]) then
			command = "help"
		end
		
		message:reply({embed = {
			title = command:gsub("^.", string.upper, 1),	-- upper bold text
			color = 6561661,
			description = locale[command],
			footer = {text = command ~= "help" and locale.embedTip or nil}
		}})
		return command.." help message"
	end,
	
	-- this function is also used by embeds, they will supply ids
	register = function (message, ids)
		local msg
		
		if not ids then
			ids = registerParse(message, "register")
			if not ids[1] then return ids end -- message for logger
		end
		
		msg, ids = actionFinalizer(message, ids, "register")
		message:reply(msg)
		return (#ids == 0 and "Successfully registered all" or ("Couldn't register "..table.concat(ids, " ")))
	end,
	
	-- this function is also used by embeds, they will supply ids
	unregister = function (message, ids)
		local msg
		
		if not ids then
			ids = registerParse(message, "unregister")
			if not ids[1] then return ids end -- message for logger
		end
		
		msg, ids = actionFinalizer(message, ids, "unregister")
		message:reply(msg)
		return (#ids == 0 and "Successfully unregistered all" or ("Couldn't unregister "..table.concat(ids, " ")))
	end,
	
	-- this function is also used by embeds, they will supply ids and target
	target = function (message, ids, target)
		if not ids then
			ids, target = complexParse(message, "target")
			if not ids[1] then return ids end -- message for logger
		end
		
		local targetCategory = client:getChannel(target)
		if targetCategory and not targetCategory.guild.me:hasPermission(targetCategory, permission.manageChannels) then
			message:reply(locale.badBotPermission.." "..targetCategory.name)
			return "Bad permissions for target"
		end
		
		target, ids = actionFinalizer(message, ids, "target"..(target or ""))
		message:reply(target)
		return (#ids == 0 and "Successfully applied target to all" or ("Couldn't apply target to "..table.concat(ids, " ")))
	end,
	
	-- this function is also used by embeds, they will supply ids and template
	template = function (message, ids, template)
		if not ids then
			ids, template = complexParse(message, "template")
			if not ids[1] then return ids end -- message for logger
		end
		
		template, ids = actionFinalizer(message, ids, "template"..(template or ""))
		message:reply(template)
		return (#ids == 0 and "Successfully applied template to all" or ("Couldn't apply template to "..table.concat(ids, " ")))
	end,
	
	limitation = function (message)
		local guild, limitation = message.content:match("limitation%s*(%d*)%s*(%d*)$")
		
		
		if limitation == "" then
			limitation, guild = guild, message.guild
		else
			guild = client:getGuild(guild)
		end
		
		if not guild then
			message:reply(locale.badServer)
			return "Didn't find the guild"
		end
		if guild and not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return "Not a member"
		end
		
		if limitation ~= "" then
			if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
				message:reply(locale.mentionInVain:format(message.author.mentionString))
				return "Bad user permissions"
			end
			limitation = tonumber(limitation)
			if not limitation or limitation > 100000 or limitation < 1 then
				message:reply(locale.limitationOOB)
				return "Limitation OOB"
			end
			
			guilds:updateLimitation(guild.id, limitation)
			message:reply(locale.limitationConfirm:format(limitation))
			return "Set new limitation"
		else
			message:reply(locale.limitationThis:format(guilds[guild.id].limitation))
			return "Sent current limitation"
		end
	end,
	
	prefix = function (message)
		local prefix = message.guild and guilds[message.guild.id].prefix or nil
		
		local guild = client:getGuild(prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(%d+).-$") or
			message.content:match("^<@.?601347755046076427>%s*prefix%s*(%d+).-$") or
			message.content:match("^<@.?676787135650463764>%s*prefix%s*(%d+).-$") or
			message.content:match("^%s*prefix%s*(%d+).-$"))
		
		if guild and not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return "Not a member"
		end
		
		local newPrefix = 
			guild and (
				prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*%d+%s*(.-)$") or
				message.content:match("^<@.?601347755046076427>%s*prefix%s*%d+%s*(.-)$") or
				message.content:match("^<@.?676787135650463764>%s*prefix%s*%d+%s*(.-)$") or
				message.content:match("^%s*prefix%s*%d+%s*(.-)$")
			) or (
				prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(.-)$") or
				message.content:match("^<@.?601347755046076427>%s*prefix%s*(.-)$") or
				message.content:match("^<@.?676787135650463764>%s*prefix%s*(.-)$") or
				message.content:match("^%s*prefix%s*(.-)$"))
		
		guild = guild or message.guild
		if not guild then
			message:reply(locale.badServer)
			return "Didn't find the guild"
		end
		if newPrefix and newPrefix ~= "" then
			if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
				message:reply(locale.mentionInVain:format(message.author.mentionString))
				return "Bad user permissions"
			end
			guilds:updatePrefix(guild.id, newPrefix)
			message:reply(locale.prefixConfirm:format(newPrefix))
			return "Set new prefix"
		else
			message:reply(locale.prefixThis:format(guilds[guild.id].prefix))
			return "Sent current prefix"
		end
	end,
	
	list = function (message)
		local guild = client:getGuild(message.content:match("list%s*(%d+)")) or message.guild
		if not guild then
			message:reply(locale.badServer)
			return "Didn't find the guild"
		elseif not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return "Not a member"
		end
		
		local lobbies = guild.voiceChannels:toArray(function (channel) return lobbies[channel.id] end)
		table.sort(lobbies, truePositionSorting)
		
		local msg = (#lobbies == 0 and locale.noLobbies or locale.someLobbies) .. "\n"
		for _,channel in ipairs(lobbies) do
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
		end
		
		message:reply(msg)
		return "Sent lobby list"
	end,
	
	stats = function (message)
		local guildID = message.content:match("stats%s*(%d+)")
		local guild = guildID == "local" and message.guild or client:getGuild(guildID)
		if guildID and not guild then
			message:reply(locale.badServer)
			return "Didn't find the guild"
		end
		if guild and not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return "Not a member"
		end
		
		local t = os.clock()
		message.channel:broadcastTyping()
		t = math.modf((os.clock() - t)*1000)
		
		local guildCount, lobbyCount, channelCount, peopleCount = #client.guilds
		if guild then
			lobbyCount, channelCount, peopleCount = #guilds[guild.id].lobbies, guilds[guild.id]:channelsCount(), channels:people(guild.id)
		else
			lobbyCount, channelCount, peopleCount = #lobbies, #channels, channels:people()
		end
		message:reply((guild and (
			lobbyCount == 1 and locale.lobby or locale.lobbies:format(lobbyCount)
			) or (
			(guildCount == 1 and lobbyCount == 1) and locale.serverLobby or string.format((
				guildCount == 1 and locale.serverLobbies or (
				lobbyCount == 1 and locale.serversLobby or 
				locale.serversLobbies)), guildCount, lobbyCount))) .. "\n" ..
			((channelCount == 1 and peopleCount == 1) and locale.channelPerson or string.format((
				channelCount == 1 and locale.channelPeople or (
				peopleCount == 1 and locale.channelsPerson or -- practically impossible, but whatever
				locale.channelsPeople)), channelCount, peopleCount)) .. "\n" ..
			string.format(locale.ping, t))
		return "Sent current stats"
	end,
	
	support = function (message)
		message:reply("https://discord.gg/tqj6jvT")
		return "Sent support invite"
	end,
	
	shutdown = function (message)
		if message then
			if message.author.id ~= "188731184501620736" then return end
			message:reply("Shutting down gracefully")
		end
		
		local status, msg = pcall(function()
			client:setGame({name = "the maintenance", type = 3})
			clock:stop()
			client:stop()
			--conn:close()
		end)
		logger:log(3, (status and "Shutdown successfull" or ("Couldn't shutdown gracefully, "..msg)))
		process:exit()
	end
}