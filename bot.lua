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
local heroesNeverDie = discordia.Emitter()
local aliveTracker = 5

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

local function getLocale (guild)
	return (guild and guilds[guild.id].locale or locale.english)
end

local embeds = setmetatable({}, {
	__index = {
		reactions = {"1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟",
			["1️⃣"] = 1, ["2️⃣"] = 2, ["3️⃣"] = 3, ["4️⃣"] = 4, ["5️⃣"] = 5, ["6️⃣"] = 6, ["7️⃣"] = 7, ["8️⃣"] = 8, ["9️⃣"] = 9, ["🔟"] = 10,
			left = "⬅", right = "➡"},
		
		new = function (self, locale, action, page, ids)
			local reactions = self.reactions
			local embed = {title = action == "register" and locale.embedRegister or locale.embedUnregister, description = ""}
			
			for i=10*(page-1)+1,10*page do
				if not ids[i] then break end
				local channel = client:getChannel(ids[i])
				embed.description = embed.description.."\n"..reactions[math.fmod(i-1,10)+1]..
					string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name)
			end
			
			return embed
		end,
		
		decorate = function (self, message)
			local reactions = self.reactions
			local embedData = self[message]
			if embedData.page ~= 1 then message:addReaction(reactions.left) end
			for i=10*(embedData.page-1)+1, 10*embedData.page do
				if not embedData.ids[i] then break end
				message:addReaction(reactions[math.fmod(i-1,10)+1])
			end
			if embedData.page ~= math.modf(#embedData.ids/10)+1 then message:addReaction(reactions.right) end
		end,
		
		send = function (self, message, action, ids)
			local embed = self:new(guilds[message.guild.id].locale, action, 1, ids)
			local newMessage = message:reply {embed = embed}
			self[newMessage] = {embed = embed, killIn = 10, ids = ids, page = 1, action = action, author = message.author}
			self:decorate(newMessage)
			
			logger:log(4, "Created embed "..newMessage.id)
			return newMessage
		end,
		
		updatePage = function (self, message, page)
			local embedData = self[message]
			embedData.embed = self:new(getLocale(message.guild), embedData.action, page, embedData.ids)
			embedData.killIn = 10
			embedData.page = page
			
			message:clearReactions()
			message:setEmbed(embedData.embed)
			self:decorate(message)
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

local actions = {
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
		
		if not message.member:hasPermission(permission.manageChannels) then
			logger:log(4, "Mention in vain")
			message:reply(getLocale(message.guild).mentionInVain:format(message.author.mentionString))
			return
		end
		
		logger:log(4, "Prefix action invoked")
		
		local prefix = message.content:match("prefix%s+(.-)$")
		
		if prefix then
			guilds:updatePrefix(message.guild.id, prefix)
			message:reply(getLocale(message.guild).prefixConfirm:format(prefix))
		else
			message:reply(string.format(guilds[message.guild.id].prefix and getLocale(message.guild).prefixThis or getLocale(message.guild).prefixAbsent, guilds[message.guild.id].prefix))
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

client:on(safeEvent('messageCreate', function (message)
	local prefix = message.guild and guilds[message.guild.id].prefix or nil
	
	if message.author.bot or (
		not message.mentionedUsers:find(function(user) return user == client.user end) and 
		not (prefix and message.content:find(prefix, 1, true)) and 	-- allow % in prefixes
		message.guild) then	-- ignore prefix req for dms
		return
	end
	
	logger:log(4, "Message received, processing...")
	
	--if message.guild then message.guild:getMember(message.author) end	-- cache the member object

	local command = prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*(%a+)") or message.content:match("^<@.?676787135650463764>%s*(%a+)")
	if not actions[command] then logger:log(4, "Nothing"); return end
	local res, msg = pcall(function() actions[command](message) end)
	if not res then 
		logger:log(1, "Couldn't process the message, %s", msg)
		client:getChannel("686261668522491980"):send("Couldn't process the message: "..message.content.."\n"..msg)
		message:reply(getLocale(message.guild).error:format(os.date("%b %d %X")).."\nhttps://discord.gg/tqj6jvT")
	end
end))

client:on(safeEvent('messageUpdate', function (message)	-- hearbeat
	if message.author.id == "601347755046076427" and message.channel.id == "676791988518912020" then
		aliveTracker = 5
		return
	end
end))

client:on(safeEvent('reactionAdd', function (reaction, userID)
	if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
		return
	end
	
	local embedData = embeds[reaction.message]
	
	logger:log(4, "Processing reaction")
	if reaction.emojiHash == "⬅" then
		embeds:updatePage(reaction.message, embedData.page - 1)
	elseif reaction.emojiHash == "➡" then
		embeds:updatePage(reaction.message, embedData.page + 1)
	else
		actions[embedData.action](reaction.message, embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]])
	end
end))

client:on(safeEvent('reactionRemove', function (reaction, userID)
	if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
		return
	end
	
	local embedData = embeds[reaction.message]
	
	logger:log(4, "Processing removed reaction")
	if embeds[reaction.message].action == "unregister" then
		actions.register(reaction.message, embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]])
	else
		actions.unregister(reaction.message, embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]])
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
	aliveTracker = aliveTracker - 1
	if aliveTracker < 0 then heroesNeverDie:emit("shutdown") end
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

heroesNeverDie:on(safeEvent('shutdown', actions.shutdown))

local sd = function () heroesNeverDie:emit("shutdown") end -- ensures graceful shutdown

process:on('sigterm', sd)
process:on('sigint', sd)

client:run('Bot '..config.token)