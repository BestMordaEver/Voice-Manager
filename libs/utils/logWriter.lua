local discordia = require "discordia"
local token = require "token"
local client = require "client"

local safeEvent = require "funcs/safeEvent"

local https = require "coro-http"
local json = require "json"

local emitter = discordia.Emitter()
local Date = discordia.Date

local insert, concat = table.insert, table.concat
local f, byte = string.format, string.byte

local function tohex (char)
	return f('%%%02X', byte(char))
end

local function send (name, text)	
	if token.pastebin then
		local res, body = https.request("POST","https://pastebin.com/api/api_post.php",{{'Content-Type','application/x-www-form-urlencoded'}},
			f("api_dev_key=%s&api_paste_name=%s&api_paste_code=%s&api_option=paste&api_paste_private=1&api_paste_expire_date=1M",
				token.pastebin, name:gsub("%W", tohex), text:gsub("%W", tohex)))

		return res.code == 200, body
	end
end
--[=[
emitter:on("hehe", send)
emitter:emit("hehe", "huehueh hehe", [[text
and text
and text
]]
..json.encode({[1]=1})
)]=]

local function logEmbed (embed)
	embed.type = nil
	return "[[ Embed\r\n{\"embed\":"..json.encode(embed).."}\r\n"
end

local function logAttachments(attachments)
	local lines = {"[[ Attachment"}
	for i, attachment in ipairs(attachments) do
		insert(lines, attachment.url)
	end
	insert(lines, "")
	return concat(lines, "\r\n")
end

local logWriter = {}
local logs = {}
--[[local actions = {
	mesageCreate = function (message)
		local log = logs[message.channel.id]
		if log then
			insert(log, f("[%s] <%s sends %s> %s\r\n%s",
				Date.fromSnowflake(message.id):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	messageUpdate = function (message)
		local file = files[message.channel.id]
		if file then
			file:write(f("[%s] <%s updates %s> %s\r\n%s",
				Date.fromTable(os.date()):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	messageUpdateUncached = function (channel, messageID)
		local file, message = files[channel.id], channel:getMessage(messageID)
		if file and message then
			file:write(f("[%s] <%s updates %s> %s\r\n%s",
				Date.fromTable(os.date()):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	messageDelete = function (message)
		local file = files[message.channel.id]
		if file then
			file:write(f("[%s] <%s deletes %s> %s\r\n%s",
				Date.fromTable(os.date()):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	messageDeleteUncached = function (channel, messageID)
		local file, message = files[channel.id], channel:getMessage(messageID)
		if file and message then
			file:write(f("[%s] <%s deletes %s> %s\r\n%s",
				Date.fromTable(os.date()):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	reactionAdd = function (reaction, userID)
		local file = files[reaction.message.channel.id]
		if file and message then
			file:write(f("[%s] <%s reacts to %s> %s",
				Date.fromTable(os.date()):toString(), userID, message.id, reaction.emojiHash))
		end
	end,
	
	reactionAddUncached = function (channel, messageID, hash, userID)
		local file = files[channel.id]
		if file then
			file:write(f("[%s] <%s reacts to %s> %s",
				Date.fromTable(os.date()):toString(), userID, messageID, hash))
		end
	end,
	
	reactionRemove = function (reaction, userID)
		local file = files[reaction.message.channel.id]
		if file and message then
			file:write(f("[%s] <%s removes reaction to %s> %s",
				Date.fromTable(os.date()):toString(), userID, message.id, reaction.emojiHash))
		end
	end,
	
	reactionRemoveUncached = function (channel, messageID, hash, userID)
		local file = files[channel.id]
		if file then
			file:write(f("[%s] <%s removes reaction to %s> %s",
				Date.fromTable(os.date()):toString(), userID, messageID, hash))
		end
	end
}

for name, event in ipairs(actions) do
	client:on(name, function(...) emitter:emit(name, ...) end)
	emitter:onSync(safeEvent(name, event))
end
emitter:on(safeEvent("resume", logWriter))
]]

function logWriter.start(channel)
	if not logs[channel.id] then
		logs[channel.id] = {
			f("Chat log of channel \"%s\" in server \"%s\"\r\nTimestamps use UTC time\r\nEmbeds can be viewed as seen in app here - https://leovoel.github.io/embed-visualizer/\r\n\r\n",
				channel.name, channel.guild.name)
		}
		
		local log = logs[channel.id]
		local message, lastMessage = channel:getFirstMessage(), channel:getLastMessage()
		if message then
			insert(log, f("[%s] <%s> %s\r\n%s%s",
				Date(message.createdAt):toString("!%Y-%m-%d %X"), message.author.name, message.content, 
				(message.embed and logEmbed(message.embed) or ""), (message.attachments and logAttachments(message.attachments) or "")))
				
			repeat
				local messages = channel:getMessagesAfter(message, 100):toArray("createdAt")
				for _, message in ipairs(messages) do
					insert(log, f("[%s] <%s> %s\r\n%s%s",
						Date(message.createdAt):toString("!%Y-%m-%d %X"), message.author.name, message.content, 
						(message.embed and logEmbed(message.embed) or ""), (message.attachments and logAttachments(message.attachments) or "")))
				end
				message = messages[#messages]
			until message == lastMessage
		end
	end
end

-- this will make sense later
function logWriter.finish(channel)
	local log = logs[channel.id]
	logs[channel.id] = nil
	return send(f("Channel \"%s\" in server \"%s\"", channel.id, channel.guild.id), concat(log))
end

return logWriter