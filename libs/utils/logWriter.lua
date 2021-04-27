local discordia = require "discordia"
local token = require "token"
local client = require "client"
local emitter = discordia.Emitter()
local safeEvent = require "funcs/safeEvent"
local https = require "coro-http"

local function tohex (char)
	return string.format('%%%02X', string.byte(char))
end

local function send (name, text)	
	if token.pastebin then
		local res, body = https.request("POST","https://pastebin.com/api/api_post.php/",{{'Content-Type','application/x-www-form-urlencoded'}},
			string.format("api_dev_key=%s&api_paste_name=%s&api_paste_code=%s&api_option=paste&api_paste_private=1&api_paste_expire_date=1M",
				token.pastebin, name:gsub("%W", tohex), text:gsub("%W", tohex)))
		
		return res.code, body
	end
end

local function logEmbed (embed)
	return "[[ Embed\r\n{"..json.encode(embed).."}\r\n"
end

local function logAttachments(attachments)
	local lines = {"[[Attachment"}
	for i, attachment in ipairs(attachments) do
		table.insert(lines, attachment.url)
	end
	table.insert(lines, "")
	return table.concat(lines, "\r\n")
end

local logWriter = {}
local logs = {}
local actions = {
	mesageCreate = function (message)
		local file = files[message.channel.id]
		if file then
			file:write(string.format("[%s] <%s sends %s> %s\r\n%s",
				Date.fromSnowflake(message.id):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	messageUpdate = function (message)
		local file = files[message.channel.id]
		if file then
			file:write(string.format("[%s] <%s updates %s> %s\r\n%s",
				Date.fromTable(os.date()):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	messageUpdateUncached = function (channel, messageID)
		local file, message = files[channel.id], channel:getMessage(messageID)
		if file and message then
			file:write(string.format("[%s] <%s updates %s> %s\r\n%s",
				Date.fromTable(os.date()):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	messageDelete = function (message)
		local file = files[message.channel.id]
		if file then
			file:write(string.format("[%s] <%s deletes %s> %s\r\n%s",
				Date.fromTable(os.date()):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	messageDeleteUncached = function (channel, messageID)
		local file, message = files[channel.id], channel:getMessage(messageID)
		if file and message then
			file:write(string.format("[%s] <%s deletes %s> %s\r\n%s",
				Date.fromTable(os.date()):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments and logAttachments(message.attachments) or "")))
		end
	end,
	
	reactionAdd = function (reaction, userID)
		local file = files[reaction.message.channel.id]
		if file and message then
			file:write(string.format("[%s] <%s reacts to %s> %s",
				Date.fromTable(os.date()):toString(), userID, message.id, reaction.emojiHash))
		end
	end,
	
	reactionAddUncached = function (channel, messageID, hash, userID)
		local file = files[channel.id]
		if file then
			file:write(string.format("[%s] <%s reacts to %s> %s",
				Date.fromTable(os.date()):toString(), userID, messageID, hash))
		end
	end,
	
	reactionRemove = function (reaction, userID)
		local file = files[reaction.message.channel.id]
		if file and message then
			file:write(string.format("[%s] <%s removes reaction to %s> %s",
				Date.fromTable(os.date()):toString(), userID, message.id, reaction.emojiHash))
		end
	end,
	
	reactionRemoveUncached = function (channel, messageID, hash, userID)
		local file = files[channel.id]
		if file then
			file:write(string.format("[%s] <%s removes reaction to %s> %s",
				Date.fromTable(os.date()):toString(), userID, messageID, hash))
		end
	end
}

for name, event in ipairs(actions) do
	client:on(name, function(...) emitter:emit(name, ...) end)
	emitter:onSync(safeEvent(name, event))
end
emitter:on(safeEvent("resume", logWriter))

function logWriter.start(channel, isFull)
	logs[channel.id] = {string.format("Chat log of channel \"%s\" in server \"%s\"\r\nTimestamps use UTC time\r\n", channel.name, channel.guild.name)}
end

function logWriter.finish()

end

return logWriter