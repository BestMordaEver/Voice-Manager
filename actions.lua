local discordia = require "discordia"
local client, logger = discordia.storage.client, discordia.storage.logger

local channels = require "./channels.lua"
local lobbies = require "./lobbies.lua"
local guilds = require "./guilds.lua"
local embeds = require "./embeds.lua"
local locale = require "./locale"

local discordia = require "discordia"
discordia.extensions.table()
local permission, channelType = discordia.enums.permission, discordia.enums.channelType

local truePositionSorting = require "./utils.lua".truePositionSorting

local function parseForIDs (message, command)			-- returns a table of all ids
	local id = message.content:match(command.."%s+(.-)$")
	if not id then
		if not message.guild then
			message:reply(locale.noID)
			return 4, "Empty input in DM"
		elseif not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
			message:reply(locale.gimmeReaction)
			return 4, "Empty input, can't do embed"
		end
		
		local ids = {}
		for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel)
			return (command == "register") == not lobbies[channel.id] and		-- embeds never offer redundant channels
				message.guild.me:hasPermission(channel.category, permission.manageChannels) and
				message.member:hasPermission(channel, permission.manageChannels)	-- non-embed related permission checks are in regunregAction
		end), truePositionSorting)) do
			table.insert(ids, channel.id)
		end
		return 4, "Empty input, sent embed "..embeds:send(message, command, ids).id
	end
	
	local ids = {}
	for ID in id:gmatch("%d+") do
		if client:getChannel(ID) then
			table.insert(ids, ID)
		end
	end
	
	if #ids == 0 then
		if not message.guild then
			message:reply(locale.onlyInServer)
			return 4, command.." by name in dm"
		end
		
		id = id:lower()
		for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) 
			return channel.name:lower() == id
		end), truePositionSorting)) do
			table.insert(ids, channel.id)
		end
		
		
		if #ids == 0 then
			message:reply(locale.badInput)
			return 4, "Didn't find the channel by name"
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
			
			if not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
				message:reply(locale.ambiguousID.."\n"..locale.gimmeReaction)
				return 4, "Ambiguous input, can't do embed"
			end
			
			local newMessage = embeds:send(message, command, ids)
			newMessage:setContent(locale.ambiguousID)
			return 4, "Ambiguous input, sent embed "..newMessage.id
		end
	else
		return ids
	end
end

local function actionFinalizer (message, action, ids)	-- register, unregister and template are painfully simmilar, unified here
	local badUser, badBot, badChannel, redundant = {}, {}, {}, {}
	
	for i,_ in ipairs(ids) do repeat
		local channel = client:getChannel(ids[i])
		if channel then
			if channel.type == channelType.voice and channel.guild:getMember(message.author) then
				if (action == "register") == not lobbies[channel.id] then
					if channel.guild:getMember(message.author):hasPermission(channel, permission.manageChannels) then
						if action == "unregister" or channel.guild.me:hasPermission(channel.category, permission.manageChannels) then
							break
						else
							table.insert(badBot, table.remove(ids, i))
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
		else break end
	until not ids[i] end

	local msg, template = "", action:match("^template(.-)$")
	if #ids > 0 then
		msg = string.format(
		action == "register" and 
			(#ids == 1 and locale.registeredOne or locale.registeredMany) or 
		action == "unregister" and 
			(#ids == 1 and locale.unregisteredOne or locale.unregisteredMany) or
		locale.newTemplate, template or #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel, guild = client:getChannel(channelID), client:getGuild(channelID)
			msg = msg..(channel and 
				string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name)
			or
				string.format(locale.channelNameCategory, "global", guild.name)
			).."\n"
			if action == "register" then
				lobbies:add(channelID)
			elseif action == "unregister" then
				lobbies:remove(channelID)
			else
				(client:getGuild(channelID) and guilds or lobbies):updateTemplate(channelID, template)
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
			table.insert(badChannel, channelID)
		end
	end

	if #badBot > 0 then
		msg = msg..(#badBot == 1 and locale.badBotPermission or locale.badBotPermissions).."\n"
		for _, channelID in ipairs(badBot) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
			table.insert(badChannel, channelID)
		end
	end

	if #badUser > 0 then
		msg = msg..(action == "register" and (#badUser == 1 and locale.badUserPermissionRegister or locale.badUserPermissionsRegister) or 
			(#badUser == 1 and locale.badUserPermissionUnregister or locale.badUserPermissionsUnregister)).."\n"
		for _, channelID in ipairs(badUser) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
			table.insert(badChannel, channelID)
		end
	end
	
	return msg, badChannel
end

local actions

actions = {
	help = function (message)
		local command = message.content:match("help%s*(.-)$")
		if command and locale[command] then
			message:reply(locale[command])
			return 4, command.." help message"
		else
			message:reply(locale.help)
			return 4, "Standard help message"
		end
	end,
	
	register = function (message, ids)
		local msg
		
		if not ids then -- ids may be sent by embed
			ids, msg = parseForIDs(message, "register")
			if msg then return ids, msg end
		end
		
		msg, ids = actionFinalizer(message, "register", ids)
		message:reply(msg)
		return 4, #ids == 0 and "Successfully registered all" or ("Couldn't register "..table.concat(ids, " "))
	end,

	unregister = function (message, ids)
		local msg
		
		if not ids then
			ids, msg = parseForIDs(message, "unregister")
			if msg then return ids, msg end
		end
		
		msg, ids = actionFinalizer(message, "unregister", ids)
		message:reply(msg)
		return 4, #ids == 0 and "Successfully unregistered all" or ("Couldn't unregister "..table.concat(ids, " "))
	end,
	
	template = function (message, ids, template)
		if not ids then
			ids = {}
			local scope
			scope, template = message.content:match('^.-template%s*"(.-)"%s*(.-)$')
			
			if scope then
				local guild, lobby = client:getGuild(scope), lobbies[scope] and client:getChannel(scope)
				if scope == "global" and message.guild then
					scope = message.guild.id
					guild = message.guild
				end
				
				if (guild and not guild:getMember(message.author)) or (lobby and not lobby.guild:getMember(message.author)) then
					message:reply(locale.notMember)
					return 4, "Not a member"
				end
				
				if template == "" then
					if guild then
						message:reply(guilds[guild.id].template and locale.globalTemplate:format(guilds[guild.id].template) or locale.defaultTemplate)
						return 4, "Sent global template"
					elseif lobby then
						message:reply(lobbies[lobby.id].template and locale.lobbyTemplate:format(lobby.name, lobbies[lobby.id].template) or locale.noTemplate)
						return 4, "Sent channel template"
					else
						if message.guild then
							for _, channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) return channel.name == scope and lobbies[channel.id] end), truePositionSorting)) do
								table.insert(ids, channel)
							end
							
							if #ids == 0 then
								message:reply(locale.badInput)
								return 4, "Didn't find the channel by name"
							elseif #ids > 1 then
								message:reply(locale.ambiguousID)
								return 4, "Ambiguous input"
							end
						else
							message:reply(locale.onlyInServer)
							return 4, "Template get by name in dm"
						end
					end
				else
					if guild or lobby then
						ids[1] = scope
					else
						for id in scope:gmatch("%d+") do
							if lobbies[id] and client:getChannel(id) then table.insert(ids, id) end
						end
						if #ids == 0 then
							if message.guild then
								scope = scope:lower()
								for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) 
									return channel.name:lower() == scope and lobbies[channel.id]
								end), truePositionSorting)) do
									table.insert(ids, channel.id)
								end
								
								if #ids == 0 then
									message:reply(locale.badInput)
									return 4, "Didn't find the channel by name"
								elseif #ids > 1 then
									if not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
										message:reply(locale.ambiguousID.."\n"..locale.gimmeReaction)
										return 4, "Ambiguous input, can't do embed"
									end
									
									local newMessage = embeds:send(message, "template"..template, ids)
									newMessage:setContent(locale.ambiguousID)
									return 4, "Ambiguous input, sent embed "..newMessage.id
								end
							else
								message:reply(locale.onlyInServer)
								return 4, "Template set by name in dm"
							end
						end
					end
				end
			else
				template = message.content:match("^.-template%s*(.-)%s*$")
				if message.guild then
					if template == "" then
						message:reply(guilds[message.guild.id].template and locale.globalTemplate:format(guilds[message.guild.id].template) or locale.defaultTemplate)
						return 4, "Sent global template"
					else
						if not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
							message:reply(locale.gimmeReaction)
							return 4, "Empty template, can't do embed"
						end
						
						for _, channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) return$ lobbies[channel.id] end), truePositionSorting)) do
							table.insert(ids, channel)
						end
						
						return 4, "Empty template, sent embed "..embeds:send(message, "template"..template, ids).id
					end
				else
					message:reply(locale.noID)
					return 4, "Empty template in dm"
				end
			end
		end

		template, ids = actionFinalizer(message, "template"..template, ids)
		message:reply(template)
		return 4, #ids == 0 and "Successfully applied template to all" or ("Couldn't apply template to "..table.concat(ids, " "))
	end,
	
	prefix = function (message)
		local prefix = message.guild and guilds[message.guild.id].prefix or nil
		
		local guild = client:getGuild(prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(%d+).-$") or
			message.content:match("^<@.?601347755046076427>%s*prefix%s*(%d+).-$") or
			message.content:match("^<@.?676787135650463764>%s*prefix%s*(%d+).-$") or
			message.content:match("^%s*prefix%s*(%d+).-$"))
		
		if guild and not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return 4, "Not a member"
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
		if newPrefix and newPrefix ~= "" then
			if not guild then
				message:reply(locale.badServer)
				return 4, "Didn't find the guild"
			end
			if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
				message:reply(locale.mentionInVain:format(message.author.mentionString))
				return 4, "Bad user permissions"
			end
			guilds:updatePrefix(guild.id, newPrefix)
			message:reply(locale.prefixConfirm:format(newPrefix))
			return 4, "Set new prefix"
		else
			message:reply(locale.prefixThis:format(guilds[guild.id].prefix))
			return 4, "Sent current prefix"
		end
	end,
	
	list = function (message)
		local guild = client:getGuild(message.content:match("list%s*(%d+)")) or message.guild
		if not guild then
			message:reply(locale.badServer)
			return 4, "Didn't find the guild"
		elseif not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return 4, "Not a member"
		end
		
		local lobbies = guild.voiceChannels:toArray(function (channel) return lobbies[channel.id] end)
		table.sort(lobbies, truePositionSorting)
		
		local msg = (#lobbies == 0 and locale.noLobbies or locale.someLobbies) .. "\n"
		for _,channel in ipairs(lobbies) do
			msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
		end
		
		message:reply(msg)
		return 4, "Sent lobby list"
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
		
		local guildID = message.content:match("stats%s*(%d+)")
		local guild = client:getGuild(guildID)
		if guildID and not guild then
			message:reply(locale.badServer)
			return 4, "Didn't find the guild"
		end
		if guild and not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return 4, "Not a member"
		end
		
		local t = os.clock()
		message.channel:broadcastTyping()
		t = math.modf((os.clock() - t)*1000)
		
		local guildCount, lobbyCount, channelCount, peopleCount = #client.guilds
		if guild then
			lobbyCount, channelCount, peopleCount = lobbies:inGuild(guild.id), channels:inGuild(guild.id), channels:people(guild.id)
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
		return 4, "Sent current stats"
	end,
	
	support = function (message)
		message:reply("https://discord.gg/tqj6jvT")
		return 4, "Sent support invite"
	end
}

return actions