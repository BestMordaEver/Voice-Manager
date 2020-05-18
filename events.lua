local discordia = require "discordia"
local client, logger, clock = discordia.storage.client, discordia.storage.logger, discordia.storage.clock

local channels = require "./channels.lua"
local lobbies = require "./lobbies.lua"
local guilds = require "./guilds.lua"
local embeds = require "./embeds.lua"

local locale = require "./locale"
local actions = require "./actions.lua"
local finalizer = require "./finalizer.lua"

local permission = discordia.enums.permission
local reactions = embeds.reactions

local function antiAction (action)
	return action == "unregister" and "register" or (action == "register" and "unregister" or "template")
end

local status = setmetatable({},{__call = function (self)
	local step = math.fmod(os.date("*t").min, 3)
	if step == 0 then -- people
		local people = channels:people()
		
		self.name =
			people == 0 and "the sound of silence" or (
			people .. (
				people == 1 and " person" or " people") .. (
				tostring(people):match("69") and " (nice!)" or ""))
		
		self.type = 2
		
	elseif step == 1 then -- channels
		local channels = #channels
		
		self.name =
			channels == 0 and "the world go by" or (
			channels .. (
				channels == 1 and " channel" or " channels") .. (
				tostring(channels):match("69") and " (nice!)" or ""))
		
		self.type = 3
		
	elseif step == 2 then -- lobbies
		local lobbies = #lobbies
		
		self.name =
			lobbies == 0 and "the world go by" or (
			lobbies .. (
				lobbies == 1 and " lobby" or " lobbies") .. (
				tostring(lobbies):match("69") and " (nice!)" or ""))
		
		self.type = 3
	end
	return self
end})

local events = {
	messageCreate = function (message)
		if message.guild and not guilds[message.guild.id] then return end
		
		local prefix = message.guild and guilds[message.guild.id].prefix or nil
		
		if message.author.bot or (
			not message.mentionedUsers:find(function(user) return user == client.user end) and 
			not (prefix and message.content:find(prefix, 1, true)) and 	-- allow % in prefixes
			message.guild) then	-- ignore prefix req for dms
			return
		end
		
		logger:log(4, "Message received, processing -> %s", message.content)
		
		if message.guild then message.guild:getMember(message.author) end	-- cache the member object

		local command = 
		prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*(%w+)") or 
			message.content:match("^<@.?601347755046076427>%s*(%w+)") or 
			message.content:match("^<@.?676787135650463764>%s*(%w+)") or
			message.content:match("^(%w+)")
		
		if not actions[command] then 
			logger:log(4, "Nothing")
			return
		else
			logger:log(4, command.." action invoked")
		end
		
		local res, msg = pcall(function() logger:log(actions[command](message)) end)
		if not res then
			message:reply(locale.error:format(os.date("%b %d %X")).."\nhttps://discord.gg/tqj6jvT")
			error(msg)
		end
		logger:log(4, command.." action complete")
	end,
	
	messageUpdate = function (message)	-- hearbeat
		if message.author.id == "601347755046076427" and message.channel.id == "676791988518912020" then
			finalizer:reset()
			return
		end
	end,
	
	reactionAdd = function (reaction, userID)
		if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
			return
		end
		
		local embedData = embeds[reaction.message]
		
		logger:log(4, "Processing reaction")
		if reaction.emojiHash == reactions.left then
			embeds:updatePage(reaction.message, embedData.page - 1)
		elseif reaction.emojiHash == reactions.right then
			embeds:updatePage(reaction.message, embedData.page + 1)
		elseif reaction.emojiHash == reactions.page then
			reaction.message.channel:broadcastTyping()
			local ids = {}
			for i = embedData.page*10 - 9, embedData.page*10 do
				if not embedData.ids[i] then break end
				table.insert(ids, embedData.ids[i])
			end
			(actions[embedData.action] or actions.template)(reaction.message, ids, embedData.action:match("^template(.+)$"))
		elseif reaction.emojiHash == reactions.all then
			reaction.message.channel:broadcastTyping();
			(actions[embedData.action] or actions.template)(reaction.message, embedData.ids, embedData.action:match("^template(.+)$"))
		else
			(actions[embedData.action] or actions.template)(reaction.message, {embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]]}, embedData.action:match("^template(.+)$"))
		end
	end,
	
	reactionRemove = function (reaction, userID)
		if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
			return
		end
		
		local embedData = embeds[reaction.message]
		
		logger:log(4, "Processing removed reaction")
		if embeds.reactions[reaction.emojiHash] then
			actions[antiAction(embedData.action)](reaction.message, {embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]]})
		elseif reaction.emojiHash == reactions.page then
			reaction.message.channel:broadcastTyping()
			local ids = {}
			for i = embedData.page*10 - 9, embedData.page*10 do
				if not embedData.ids[i] then break end
				table.insert(ids, embedData.ids[i])
			end
			actions[antiAction(embedData.action)](reaction.message, ids, embedData.action:match("^template(.+)$"))
		elseif reaction.emojiHash == reactions.all then
			reaction.message.channel:broadcastTyping();
			actions[antiAction(embedData.action)](reaction.message, embedData.ids, embedData.action:match("^template(.+)$"))
		end
	end,
	
	guildCreate = function (guild)
		guilds:add(guild.id)
		client:getChannel("676432067566895111"):send(guild.name.." added me!\n")
	end,
	
	guildDelete = function (guild)
		guilds:remove(guild.id)
		for _,channel in pairs(guild.voiceChannels) do 
			if channels[channel.id] then channels:remove(channel.id) end 
			if lobbies[channel.id] then lobbies:remove(channel.id) end
		end
		client:getChannel("676432067566895111"):send(guild.name.." removed me!\n")
	end,
	
	voiceChannelJoin = function (member, channel)
		if lobbies[channel.id] then
			logger:log(4, member.user.id.." joined lobby "..channel.id)
			local category = channel.category or channel.guild
			local name = lobbies[channel.id].template or guilds[channel.guild.id].template or "%nickname's% channel"
			if name:match("%%.-%%") then
				local nickname = member.nickname or member.user.name
				local rt = {
					nickname = nickname,
					name = member.user.name,
					tag = member.user.tag,
					["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
					["name's"] = member.user.name .. (member.user.name:sub(-1,-1) == "s" and "'" or "'s")
				}
				name = name:gsub("%%(.-)%%", rt)
			end
			
			local newChannel = category:createVoiceChannel(name)
			member:setVoiceChannel(newChannel.id)
			channels:add(newChannel.id)
			
			logger:log(4, "Created "..newChannel.id.." in "..channel.guild.id)
			
			newChannel:setUserLimit(channel.userLimit)
			if channel.guild.me:getPermissions(channel):has(permission.manageRoles, permission.manageChannels, permission.muteMembers, permission.deafenMembers, permission.moveMembers) then
				newChannel:getPermissionOverwriteFor(member):allowPermissions(permission.manageChannels, permission.muteMembers, permission.deafenMembers, permission.moveMembers)
			end
		end
	end,
	
	voiceChannelLeave = function (member, channel)
		if not channel then return end	-- until this is fixed
		if channels[channel.id] then
			if #channel.connectedMembers == 0 then
				channel:delete()
				logger:log(4, "Deleted "..channel.id)
			end
		end
	end,
	
	channelDelete = function (channel)
		lobbies:remove(channel.id)
		channels:remove(channel.id)
	end,
	
	ready = function ()
		guilds:load()
		lobbies:load()
		channels:load()
		clock:start()
		
		client:setGame(status())
		client:getChannel("676432067566895111"):send("I'm listening")
	end,

	min = function (date)
		client:getChannel("676791988518912020"):getMessage("692117540838703114"):setContent(os.date())
		channels:cleanup()
		embeds:tick()
		client:setGame(status())
		
		if finalizer:tick() or (channels:people() == 0 and os.clock() > 86000) then finalizer:kill() end
	end,
	
	hour = require "./sendStats.lua"
}

local function safeEvent (self, name)
	return name, function (...)
		local success, err = pcall(self[name], ...)
		if not success then
			logger:log(1, "Error on %s: %s", name, err)
			client:getChannel("686261668522491980"):sendf("Error on %s: %s", name, err)
		end
	end
end

return setmetatable(events, {__call = safeEvent})