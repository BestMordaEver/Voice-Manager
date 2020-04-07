local discordia = require "discordia"
local config = require "./config.lua"
local https = require "coro-http"
local json = require "json"
local conn = require "sqlite3".open("data.db")
local locale = require "./locale.lua"
discordia.extensions.table()

local client = discordia.Client()
local clock = discordia.Clock()
local logger = discordia.Logger(4, '%F %T')

local permission, channelType = discordia.enums.permission, discordia.enums.channelType

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

local channels, lobbies, servers, embeds
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
		
		cleanup = function (self)
			for channelID,_ in pairs(self) do
				local channel = client:getChannel(channelID)
				if channel then
					if #channel.connectedMembers == 0 then
						channel:delete()
					end
				end
			end
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
				if not conn:exec("SELECT * FROM guilds WHERE locale = '"..localeName.."' AND id = "..guildID) then
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
				if not conn:prepare("SELECT * FROM guilds WHERE prefix = ? AND id = ?"):bind(prefix, guildID):step() then
					conn:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"):bind(prefix, guildID):step()	-- don't even think about it
					logger:log(4, "DATABASE: Updated prefix for "..guildID)
				end
			end
		end
	}
})

embeds = setmetatable({}, {
	__index = {
		reactions = {"1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟", 
			lobby = "🛃", channel = "🆕", none = "🆓",
			left = "⬅", right = "➡", register = "✅", unregister = "❌", update = "🔄"},
		
		new = function (self, locale, action, page, ids)
			local reactions = self.reactions
			local embed = {
				title = action == "id" and locale.embedID or (
					action == "register" and locale.embedRegister or locale.embedUnregister),
				description = "",
				footer = {text = action == "id" and "" or locale.embedFooter}
			}
			local clickable = {count = 0}
			for i=10*(page-1)+1,10*page do
				if not ids[i] then break end
				local id = ids[i]
				local channel = client:getChannel(id)
				
				if (action == "unregister" and lobbies[id]) or (action == "register" and not channels[id] and not lobbies[id]) then
					clickable.count = clickable.count + 1
					clickable[reactions[clickable.count]] = id
				end
				
				embed.description = embed.description.."\n"..(
					channels[id] and reactions.channel or (
					lobbies[id] and (action == "unregister" and reactions[clickable.count] or reactions.lobby) or (
					action == "register" and reactions[clickable.count] or reactions.none)))
					.." "
					..(action == "id" and 
						string.format(channel.category and locale.channelIDNameCategory or "`%s` -> `%s`", channel.id, channel.name, channel.category and channel.category.name) or
						string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name))
			end
			return embed, clickable
		end,
		
		decorate = function (self, message, action, clickableCount)
			local reactions = self.reactions
			if self[message].page ~= 1 then message:addReaction(reactions.left) end
			for i=1, clickableCount do
				message:addReaction(reactions[i])
			end
			if self[message].page ~= math.modf(#self[message].ids/10)+1 then message:addReaction(reactions.right) end
			
			if action ~= "register" then message:addReaction(reactions.register) end
			if action ~= "unregister" then message:addReaction(reactions.unregister) end
			if action ~= "id" then message:addReaction(reactions.update) end
		end,
		
		send = function (self, message, action, ids)
			local embed, clickable = self:new(guilds[message.guild.id].locale, action, 1, ids)
			local newMessage = message:reply {content = guilds[message.guild.id].locale.embedSigns, embed = embed}
			self[newMessage] = {embed = embed, killIn = 10, ids = ids, clickable = clickable, page = 1, action = action}
			self:decorate(newMessage, action, clickable.count)
			
			logger:log(4, "Created embed "..newMessage.id)
		end,
		
		update = function (self, message)
			local embedData = self[message]
			embedData.embed, embedData.clickable = self:new(guilds[message.guild.id].locale, embedData.action, embedData.page, embedData.ids)
			embedData.killIn = 10
			
			message:clearReactions()
			message:setEmbed(embedData.embed)
			self:decorate(message, embedData.action, embedData.clickable.count)
		end,
		
		updateAction = function (self, message, action)
			local embedData = self[message]
			embedData.embed, embedData.clickable = self:new(guilds[message.guild.id].locale, action, embedData.page, embedData.ids)
			embedData.killIn = 10
			embedData.action = action
			
			message:clearReactions()
			message:setEmbed(embedData.embed)
			self:decorate(message, action, embedData.clickable.count)
		end,
		
		updatePage = function (self, message, page)
			local embedData = self[message]
			embedData.embed, embedData.clickable = self:new(guilds[message.guild.id].locale, embedData.action, page, embedData.ids)
			embedData.killIn = 10
			embedData.page = page
			
			message:clearReactions()
			message:setEmbed(embedData.embed)
			self:decorate(message, embedData.action, embedData.clickable.count)
		end,
		
		tick = function (self)
			for message, embedData in pairs(self) do
				if client:getChannel(message.channel):getMessage(message) then
					embedData.killIn = embedData.killIn - 1
					if embedData.killIn == 0 then
						self[message] = nil 
					end
				else
					self[message] = nil
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
			message:reply(guilds[message.guild.id].locale.mentionInVain:format(message.author.mentionString))
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
			local ids = {}
			for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(), truePositionSorting)) do
				table.insert(ids, channel.id)
			end
			embeds:send(message, command, ids)
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
			local channels = message.guild.voiceChannels:toArray(function (channel) 
				return channel.name:lower() == id and (command == commands.unregister and lobbies[channel.id] or command ~= commands.unregister)
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
	
	[commands.register] = function (message, id)
		if id then -- sent by embed
			lobbies:add(id)
			logger:log(4, "Registered "..id.." successfully")
			return
		end
		
		local ids = actions.regFilter(message, commands.register)
		if not ids then return end
		
		local msg = string.format(#ids == 1 and guilds[message.guild.id].locale.registeredOne or guilds[message.guild.id].locale.registeredMany, #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and guilds[message.guild.id].locale.channelIDNameCategory or "`%s` -> `%s`", channel.id, channel.name, channel.category and channel.category.name).."\n"
			lobbies:add(channelID)
		end
		message:reply(msg)
		logger:log(4, "Registered "..table.concat(ids, " ").." successfully")
	end,

	[commands.unregister] = function (message, id)
		if id then -- sent by embed
			lobbies:remove(id)
			logger:log(4, "Unregistered "..id.." successfully")
			return
		end
	
		local ids = actions.regFilter(message, commands.unregister)
		if not ids then return end
		
		local msg = string.format(#ids == 1 and guilds[message.guild.id].locale.unregisteredOne or guilds[message.guild.id].locale.unregisteredMany, #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(channel.category and guilds[message.guild.id].locale.channelIDNameCategory or "`%s` -> `%s`", channel.id, channel.name, channel.category and channel.category.name).."\n"
			lobbies:remove(channelID)
		end
		message:reply(msg)
		logger:log(4, "Unregistered "..table.concat(ids, " ").." successfully")
	end,
	
	[commands.id] = function (message, target)
		if not actions.permCheck(message) then return end
		
		logger:log(4, "ID action invoked")
		
		target = target or message.content:match(commands.id.."%s+(.-)$")
		local ids = {}
		for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) 
			return target and (channel.name:lower() == target or (channel.category and channel.category.name:lower() == target)) or not target
		end), truePositionSorting)) do
			table.insert(ids, channel.id)
		end
		
		embeds:send(message, "id", ids)
	end,
	
	[commands.language] = function (message)
		if not actions.permCheck(message) then return end
		logger:log(4, "Language action invoked")
		
		local lang = (message.content:match(commands.language.."%s+(.-)$") or ""):lower()
		
		if locale[lang] then
			guilds:updateLocale(message.guild.id, lang)
			message:reply(guilds[message.guild.id].locale.updatedLocale)
		else
			logger:log(4, "No language '%s' found", lang)
			local msg = guilds[message.guild.id].locale.availableLanguages
			for langName, _ in pairs(locale) do
				msg = msg.." "..langName..","
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
			message:reply(guilds[message.guild.id].locale.prefixConfirm:format(prefix))
		else
			message:reply(string.format(guilds[message.guild.id].prefix and guilds[message.guild.id].locale.prefixThis or guilds[message.guild.id].locale.prefixAbsent, guilds[message.guild.id].prefix))
		end
	end,
	
	[commands.list] = function (message)
		logger:log(4, "List action invoked")
		
		local ids = {}
		for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) return lobbies[channel.id] end), truePositionSorting)) do
			table.insert(ids, channel.id)
		end
		
		embeds:send(message, "unregister", ids)
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
		
		local guildCount, lobbyCount, channelCount, peopleCount = #client.guilds, #lobbies, #channels, channels:people()
		message:reply(string.format(
			(guildCount == 1 and lobbyCount == 1) and guilds[message.guild.id].locale.serverLobby or (
			guildCount == 1 and guilds[message.guild.id].locale.serverLobbies or (
			lobbyCount == 1 and guilds[message.guild.id].locale.serversLobby or 
			guilds[message.guild.id].locale.serversLobbies)), guildCount, lobbyCount) .. "\n" ..
		string.format(
			(channelCount == 1 and peopleCount == 1) and guilds[message.guild.id].locale.channelPerson or (
			channelCount == 1 and guilds[message.guild.id].locale.channelPeople or (
			peopleCount == 1 and guilds[message.guild.id].locale.channelsPerson or -- practically impossible, but whatever
			guilds[message.guild.id].locale.channelsPeople)), channelCount, peopleCount) .. "\n" ..
		string.format(guilds[message.guild.id].locale.ping, t))
	end,
	
	[commands.support] = function (message)
		logger:log(4, "Support action invoked")
		message:reply("https://discord.gg/tqj6jvT")
	end
}

local reactionAction = {
	["⬅"] = function (message)
		embeds:updatePage(message, embeds[message].page - 1)
	end,
	
	["➡"] = function (message)
		embeds:updatePage(message, embeds[message].page + 1)
	end,
	
	["✅"] = function (message)
		embeds:updateAction(message, "register")
	end,
	
	["❌"] = function (message)
		embeds:updateAction(message, "unregister")
	end,
	
	["🔄"] = function (message)
		embeds:update(message)
	end
}

client:on(safeEvent('messageCreate', function (message)
	if message.channel.type ~= channelType.text and not message.author.bot then	-- sent to pm, no guild
		message:reply("I can only be used in servers. Mention me within the server to get the help message.")
		return
	end
	
	if message.author.bot or (
		not message.mentionedUsers:find(function(user) return user == client.user end) and 
		not (guilds[message.guild.id].prefix and message.content:find(guilds[message.guild.id].prefix, 1, true))) then	-- allow % in prefixes
		return
	end
	
	logger:log(4, "Message received, processing...")
	if not message.guild.me:getPermissions(message.channel):has(permission.manageChannels, permission.moveMembers) then
		message:reply(guilds[message.guild.id].locale.badPermissions)
	end
	
	local command = message.content:match("%s(%a+)")
	if not command then command = commands.help end
	local res, msg = pcall(function() if actions[command] then actions[command](message) end end)
	if not res then 
		logger:log(1, "Couldn't process the message, %s", msg)
		client:getChannel("686261668522491980"):send("Couldn't process the message: "..message.content.."\n"..msg)
		message:reply(message.author.id ~= "188731184501620736"
			and (guilds[message.guild.id].locale.error:format(os.date("%b %d %X")).."\nhttps://discord.gg/tqj6jvT")
			or "You done goofed")
	end
end))

client:on(safeEvent('reactionAdd', function (reaction, userID)
	if not (embeds[reaction.message] and reaction.message.guild and reaction.message.guild:getMember(userID):hasPermission(permission.manageChannels)) or 
		client:getUser(userID).bot or not reaction.me then return end
	
	logger:log(4, "Processing reaction")
	if reactionAction[reaction.emojiHash] then
		reactionAction[reaction.emojiHash](reaction.message)
	else
		if embeds[reaction.message].action == "register" then
			actions.register(reaction.message, embeds[reaction.message].clickable[reaction.emojiHash])
		else
			actions.unregister(reaction.message, embeds[reaction.message].clickable[reaction.emojiHash])
		end
	end
end))

client:on(safeEvent('reactionRemove', function (reaction, userID)
	if not (embeds[reaction.message] and reaction.message.guild and reaction.message.guild:getMember(userID):hasPermission(permission.manageChannels)) or 
		client:getUser(userID).bot or not reaction.me then return end
	
	logger:log(4, "Processing removed reaction")
	if embeds[reaction.message].action == "unregister" then
		actions.register(reaction.message, embeds[reaction.message].clickable[reaction.emojiHash])
	else
		actions.unregister(reaction.message, embeds[reaction.message].clickable[reaction.emojiHash])
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
	client:getChannel("676791988518912020"):getMessage("692117540838703114"):setContent(os.date())
	channels:cleanup()
	embeds:tick()
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