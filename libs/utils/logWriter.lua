local discordia = require "discordia"
local client = require "client"

local safeEvent = require "funcs/safeEvent"

local json = require "json"

local emitter = discordia.Emitter()

local insert, concat = table.insert, table.concat
local f = string.format

local function logEmbed (embed)
	embed.type = nil
	return "[[ Embed\n{\"embed\":"..json.encode(embed).."}\n"
end

local function logAttachments(attachments)
	local lines = {"[[ Attachment"}
	for i, attachment in ipairs(attachments) do
		insert(lines, attachment.url)
	end
	insert(lines, "")
	return concat(lines, "\n")
end

local function logReactions(reactions)
	local lines = {"[[Reactions"}
	for _, reaction in pairs(reactions) do
		insert(lines, f("\n:%s: - ", reaction.emojiHash))
		if reaction.count > 25 then
			insert(lines, f("%d users", reaction.count))
		else
			for _, user in pairs(reaction:getUsers()) do
				insert(lines, f("%s, ", user.name))
			end
			lines[#lines] = lines[#lines]:sub(1,-3)
		end
	end
end

local writerMeta = {
	__index = {
		messageCreate = function (self, message)
			insert(self, f("[%s] <%s sends %s> %s\r\n%s",
				message:getDate():toString("!%Y-%m-%d %H:%M:%S"), message.author.tag, message.id, message.content,
				(#message.reactions > 0 and logReactions(message.reactions) or "")
					..
				(message.embed and logEmbed(message.embed) or "")
					..
				(message.attachments and logAttachments(message.attachments) or ""))
			)
		end,

		messageUpdate = function (self, message)
			insert(self, f("[%s] <%s edits %s> %s\r\n%s",
				os.date("!%Y-%m-%d %H:%M:%S"), message.author.tag, message.id, message.content, 
				(#message.reactions > 0 and logReactions(message.reactions) or "")
					..
				(message.embed and logEmbed(message.embed) or "")
					..
				(message.attachments and logAttachments(message.attachments) or ""))
			)
		end,

		messageUpdateUncached = function (self, channel, messageID)
			local message = channel:getMessage(messageID)
			if message then
				insert(self, f("[%s] <%s edits %s> %s\r\n%s",
					os.date("!%Y-%m-%d %H:%M:%S"), message.author.tag, message.id, message.content, 
					(#message.reactions > 0 and logReactions(message.reactions) or "")
						..
					(message.embed and logEmbed(message.embed) or "")
						..
					(message.attachments and logAttachments(message.attachments) or ""))
				)
			else
				insert(self, f("[%s] <%s is edited>", os.date("!%Y-%m-%d %H:%M:%S"), messageID))
			end
		end,

		messageDelete = function (self, message)
			insert(self, f("[%s] <%s is deleted>", os.date("!%Y-%m-%d %H:%M:%S"), message.id))
		end,

		messageDeleteUncached = function (self, channel, messageID)
			insert(self, f("[%s] <%s is deleted>", os.date("!%Y-%m-%d %H:%M:%S"), messageID))
		end,

		reactionAdd = function (self, reaction, userID)
			insert(self, f("[%s] <%s reacts to %s> %s", os.date("!%Y-%m-%d %H:%M:%S"), client:getUser(userID).tag, reaction.message.id, reaction.emojiHash))
		end,

		reactionAddUncached = function (self, channel, messageID, hash, userID)
			insert(self, f("[%s] <%s reacts to %s> %s", os.date("!%Y-%m-%d %H:%M:%S"), client:getUser(userID).tag, messageID, hash))
		end,

		reactionRemove = function (self, reaction, userID)
			insert(self, f("[%s] <%s removes reaction from %s> %s", os.date("!%Y-%m-%d %H:%M:%S"), client:getUser(userID).tag, reaction.message.id, reaction.emojiHash))
		end,

		reactionRemoveUncached = function (self, channel, messageID, hash, userID)
			insert(self, f("[%s] <%s removes reaction from %s> %s", os.date("!%Y-%m-%d %H:%M:%S"), client:getUser(userID).tag, messageID, hash))
		end
	}
}

local writers = {}
local Overseer = {}
Overseer.track = function (channel)
	if not writers[channel.id] then
		writers[channel.id] = setmetatable({
		f("Chat log of channel \"%s\" in server \"%s\"\nTimestamps use UTC time\nEmbeds can be viewed as seen in app here - https://leovoel.github.io/embed-visualizer/\n\n",
			channel.name, channel.guild.name)},writerMeta)
	end
	return writers[channel.id]
end

Overseer.resume = function (channel)
	local writer = Overseer.track(channel)

	local message, lastMessage = channel:getFirstMessage(), channel:getLastMessage()

	if message then
		writer:messageCreate(message)

		while message ~= lastMessage do
			local messages = channel:getMessagesAfter(message, 100)
			if messages then
				messages = messages:toArray("createdAt")
				for _, message in ipairs(messages) do
					writer:messageCreate(message)
				end
				message = messages[#messages]
			else
				break
			end
		end
	end
end

Overseer.stop = function (channelID)
	local writer = writers[channelID]
	writers[channelID] = nil
	return concat(writer)
end

Overseer.events = {
	messageCreate = function (message)
		if writers[message.channel.id] then
			writers[message.channel.id]:messageCreate(message)
		end
	end,

	messageUpdate = function (message)
		if writers[message.channel.id] then
			writers[message.channel.id]:messageUpdate(message)
		end
	end,

	messageUpdateUncached = function (channel, messageID)
		if writers[channel.id] then
			writers[channel.id]:messageUpdateUncached(channel, messageID)
		end
	end,

	messageDelete = function (message)
		if writers[message.channel.id] then
			writers[message.channel.id]:messageDelete(message)
		end
	end,

	messageDeleteUncached = function (channel, messageID)
		if writers[channel.id] then
			writers[channel.id]:messageDeleteUncached(channel, messageID)
		end
	end,

	reactionAdd = function (reaction, userID)
		if writers[reaction.message.channel.id] then
			writers[reaction.message.channel.id]:reactionAdd(reaction, userID)
		end
	end,

	reactionAddUncached = function (channel, messageID, hash, userID)
		if writers[channel.id] then
			writers[channel.id]:reactionAddUncached(channel, messageID, hash, userID)
		end
	end,

	reactionRemove = function (reaction, userID)
		if writers[reaction.message.channel.id] then
			writers[reaction.message.channel.id]:reactionRemove(reaction, userID)
		end
	end,

	reactionRemoveUncached = function (channel, messageID, hash, userID)
		if writers[channel.id] then
			writers[channel.id]:reactionRemoveUncached(channel, messageID, hash, userID)
		end
	end
}


for name, event in pairs(Overseer.events) do
	client:on(name, function (...) emitter:emit(name, ...) end)
	emitter:onSync(safeEvent(name, event))
end

return Overseer