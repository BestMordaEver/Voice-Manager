-- all event preprocessing happens here

local timer = require "timer"

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

-- register -> unregister; unregister -> register; templateblabla -> template; targetblabla -> target
local function antiAction (action)
	return action == "unregister" and "register" or 
		action == "register" and "unregister" or 
			action:match("^template") and "template" or "target"
end

-- message is a discord object, if it doesn't have guild property - it's a DM
local function logAction (message, logMsg)
	if message.guild then
		logger:log(4, "GUILD %s USER %s: %s", message.guild.id, message.author.id, logMsg)
	else
		logger:log(4, "DM %s: %s", message.author.id, logMsg)
	end
end

--[[
status generating function
cycles 3 different metrics every minute
bots still can't do custom statuses ;^;
]]
local status = function ()
	local self = {
	-- type - see enumeration activityType (https://github.com/SinisterRectus/Discordia/wiki/Enumerations), determines first word
	-- name - everything after first word
	}

	-- determine the cycle
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
end

--[[
events are listed by name here, discordia events may differ from OG discord events for sake of convenience
full list and arguments - https://github.com/SinisterRectus/Discordia/wiki/Events
]]
local events = {
	messageCreate = function (message)
		-- ignore non-initialized guilds
		if message.guild and not guilds[message.guild.id] then return end
		
		local prefix = message.guild and guilds[message.guild.id].prefix or nil
		
		-- good luck with this one :3
		if message.author.bot or ( -- ignore bots
			not message.mentionedUsers:find(function(user) return user == client.user end) and -- find mentions
			not (prefix and message.content:find(prefix, 1, true)) and 	-- find prefix
			message.guild) then	-- of just roll with it if dm
			return
		end
		
		logAction(message, "=> "..message.content)
		
		-- cache the member object just in case
		if message.guild then message.guild:getMember(message.author) end
		
		-- find the request
		local content = 
		prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*(.-)$") or
			message.content:match("^<@.?601347755046076427>%s*(.-)$") or
			message.content:match("^<@.?676787135650463764>%s*(.-)$") or	-- stop discriminating LabRat
			message.content
			
		-- what command is it?
		local command = content == "" and "help" or content:match("^(%w+)")
		
		if actions[command] then 
			logAction(message, command.." action invoked")
		else
			logAction(message, "Nothing")
			return
		end
		
		-- call the command, log it, and all in protected call
		local res, msg = pcall(logAction, message, actions[command](message))
		
		-- notify user if failed
		if not res then
			message:reply(locale.error:format(os.date("%b %d %X")).."\nhttps://discord.gg/tqj6jvT")
			error(msg)
		end
		
		logAction(message, command .. " action completed")
	end,
	
	messageUpdate = function (message)	-- hearbeat check
		if message.author.id == "601347755046076427" and message.channel.id == "676791988518912020" then
			finalizer:reset()
			return
		end
	end,
	
	messageDelete = function (message)	-- in case embed gets deleted
		if embeds[message] then embeds[message] = nil end
	end,
	
	reactionAdd = function (reaction, userID) -- embeds processing
		-- check extensively if it's even our business
		if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
			return
		end
		
		local embedData = embeds[reaction.message]
		
		logger:log(4, "GUILD %s USER %s on EMBED %s => added %s", reaction.message.guild.id, userID, reaction.message.id, reactions[reaction.emojiHash])
		
		-- just find corresponding emoji and pass instructions to embed
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
			(actions[embedData.action] or actions[embedData.action:match("^template")] or actions[embedData.action:match("^target")])
				(reaction.message, ids, embedData.action:match("^template(.+)$") or embedData.action:match("^target(.+)$"))
		elseif reaction.emojiHash == reactions.all then
			reaction.message.channel:broadcastTyping(); -- without semicolon next parenthesis is interpreted as a function call :\
			(actions[embedData.action] or actions[embedData.action:match("^template")] or actions[embedData.action:match("^target")])
				(reaction.message, embedData.ids, embedData.action:match("^template(.+)$") or embedData.action:match("^target(.+)$"))
		elseif reaction.emojiHash == reactions.stop then
			embeds[reaction.message] = nil
			reaction.message:delete()
		else -- assume a number emoji
			(actions[embedData.action] or actions[embedData.action:match("^template")] or actions[embedData.action:match("^target")])
				(reaction.message, {embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]]}, 
					embedData.action:match("^template(.+)$") or embedData.action:match("^target(.+)$"))
		end
	end,
	
	reactionRemove = function (reaction, userID) -- same but opposite
		if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
			return
		end
		
		local embedData = embeds[reaction.message]
		
		logger:log(4, "GUILD %s USER %s on EMBED %s => removed %s", reaction.message.guild.id, userID, reaction.message.id, reactions[reaction.emojiHash])
		
		if embeds.reactions[reaction.emojiHash] then
			actions[antiAction(embedData.action)](reaction.message, {embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]]})
		elseif reaction.emojiHash == reactions.page then
			reaction.message.channel:broadcastTyping()
			local ids = {}
			for i = embedData.page*10 - 9, embedData.page*10 do
				if not embedData.ids[i] then break end
				table.insert(ids, embedData.ids[i])
			end
			actions[antiAction(embedData.action)](reaction.message, ids)
		elseif reaction.emojiHash == reactions.all then
			reaction.message.channel:broadcastTyping();
			actions[antiAction(embedData.action)](reaction.message, embedData.ids)
		end
	end,
	
	guildCreate = function (guild) -- triggers whenever new guild appears in bot's scope
		guilds:add(guild.id)
		client:getChannel("676432067566895111"):send(guild.name.." added me!\n")
	end,
	
	guildDelete = function (guild) -- same but opposite
		guilds:remove(guild.id)
		for _,channel in pairs(guild.voiceChannels) do 
			if channels[channel.id] then channels:remove(channel.id) end 
			if lobbies[channel.id] then lobbies:remove(channel.id) end
		end
		client:getChannel("676432067566895111"):send(guild.name.." removed me!\n")
	end,
	
	voiceChannelJoin = function (member, lobby) -- your purpose!
		if lobby and lobbies[lobby.id] then
			logger:log(4, "GUILD %s LOBBY %s: %s joined", lobby.guild.id, lobby.id, member.user.id)
			
			if guilds[lobby.guild.id].limitation <= guilds[lobby.guild.id].channels then return end
			
			-- parent to which a new channel will be attached
			local category = client:getChannel(lobbies[lobby.id].target) or lobby.category or lobby.guild
			
			-- determine new channel name
			local name = lobbies[lobby.id].template or guilds[lobby.guild.id].template or "%nickname's% channel"
			local position = lobbies:attachChild(lobby.id, true)
			local needsMove = name:match("%%counter%%") and true
			if name:match("%%.-%%") then
				local uname = member.user.name
				local nickname = member.nickname or uname
				local game = (member.activity and (member.activity.type == 0 or member.activity.type == 1)) and member.activity.name or "no game"
				
				local rt = {
					nickname = nickname,
					name = uname,
					tag = member.user.tag,
					game = game,
					counter = position,
					["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
					["name's"] = uname .. (uname:sub(-1,-1) == "s" and "'" or "'s")
				}
				name = name:gsub("%%(.-)%%", rt)
			end
			
			local newChannel = category:createVoiceChannel(name)
			
			-- did we fail? statistics say "probably yes!"
			if newChannel then
				member:setVoiceChannel(newChannel.id)
				channels:add(newChannel.id, lobby.id, lobbies:attachChild(lobby.id, newChannel.id, position))
				guilds[lobby.guild.id].channels = guilds[lobby.guild.id].channels + 1
				newChannel:setUserLimit(lobby.userLimit)
				
				-- if given permissions, allow user moderation
				if lobby.guild.me:getPermissions(lobby):has(permission.manageRoles, permission.manageChannels, permission.muteMembers, permission.deafenMembers, permission.moveMembers) then
					newChannel:getPermissionOverwriteFor(member):allowPermissions(permission.manageChannels, permission.muteMembers, permission.deafenMembers, permission.moveMembers)
				end
				
				if needsMove then
					local children, distance = lobbies[lobby.id].children, 0
					repeat
						distance = distance + 1
					until children[position + distance] ~= nil or position + distance > children.max
					if position + distance <= children.max then
						newChannel:moveUp(newChannel.position - client:getChannel(children[position + distance]).position)
					end
					
				end
			else
				logger:log(2, "GUILD %s LOBBY %s: Couldn't create new channel for %s", lobby.guild.id, lobby.id, member.user.id)
			end
		end
	end,
	
	voiceChannelLeave = function (member, channel) -- now remove the unwanted corpses!
		if channel and channels[channel.id] then
			if #channel.connectedMembers == 0 then
				channel:delete()
				logger:log(4, "GUILD %s: Deleted %s", channel.guild.id, channel.id)
			end
		end
	end,
	
	channelDelete = function (channel) -- and make sure there are no traces!
		if lobbies[channel.id] then
			lobbies:remove(channel.id)
			guilds[channel.guild.id].lobbies:remove(channel.id)
		end
		if channels[channel.id] then
			channels:remove(channel.id)
			lobbies:detachChild(channel.id)
			guilds[channel.guild.id].channels = guilds[channel.guild.id].channels - 1
		end
	end,
	
	ready = function ()
		channels:load()
		lobbies:load()
		guilds:load()
		clock:start()
		
		client:setGame(status())
		client:getChannel("676432067566895111"):send("I'm listening")
	end,
	
	error = function (err)
		local channel = err:match("404 %- Not Found : DELETE.-channels/(%d+)")
		if channel then 
			if channels[channel] then channels:remove(channel) end
			if lobbies[channel] then lobbies:remove(channel) end
		end
	end,

	min = function (date)
		-- hearbeat happens
		client:getChannel("676791988518912020"):getMessage("692117540838703114"):setContent(os.date())
		
		channels:cleanup()
		embeds:tick()
		client:setGame(status())
		
		-- hearbeat is partial? stop it!
		if finalizer:tick() or (channels:people() == 0 and os.clock() > 86000) then finalizer:kill() end
	end,
	
	hour = require "./sendStats.lua"
}

local function safeEvent (self, name)
	-- will be sent to emitter:on() style function
	-- name corresponds to event name
	-- function starts protected calls of event responding functions from "events"
	return name, function (...)
		local success, err = pcall(self[name], ...)
		if not success then
			logger:log(1, "Error on %s: %s", name, err)
			client:getChannel("686261668522491980"):sendf("Error on %s: %s", name, err)
		end
	end
end

return setmetatable(events, {__call = safeEvent})