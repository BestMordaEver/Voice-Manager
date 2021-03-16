local discordia = require "discordia"
local client = require "client"
local emitter = discordia.Emitter()
local safeEvent = require "funcs/safeEvent"

local function logEmbed (embed)
	local lines = {"[[ Embed"}
	table.insert(lines, embed.title)
	table.insert(lines, embed.url)
	table.insert(lines, embed.description)
	
	
	
	table.insert(lines, "\r\n")
end

local logWriter = {}
local files = {}
local actions = {
	mesageCreate = function (message)
		local file = files[message.channel.id]
		if file then
			file:write(string.format("[%s] <%s sends %s> %s\r\n%s",
				Date.fromSnowflake(message.id):toString(), message.author.id, message.id, message.content, 
				(message.embed and logEmbed(message.embed) or "") .. (message.attachments[1] and logAttachments(message.attachments) or ""))
		end
	end,
	messageUpdate,
	messageUpdateUncached,
	messageDelete,
	messageDeleteUncached,
	reactionAdd,
	reactionAddUncached,
	reactionRemove,
	reactionRemoveUncached,
	pinsUpdate
}

for name, event in ipairs(actions) do
	client:on(name, function(...) emitter:emit(name, ...) end)
	emitter:onSync(safeEvent(name, event))
end
emitter:on(safeEvent("resume", logWriter

local actions = {
	mesageCreate = "[%s] <%s sends %s> %s\r\n%s\r\n",
	messageUpdate = "[%s] <%s updates %s> %s\r\n%s",
	messageDelete = "[%s] <%s deletes %s>",
	messageReply = "[%s] <%s sends %s> In reply to %s\r\n%s\r\n%s"
	reactionAdd = "[%s] <%s reacts to %s> %s",
	reactionRemove = "[%s] <%s removes reaction to %s> %s",
	pinsUpdate = "[%s] <%s pins %s>"
}

function logWriter.start(channel, isFull)
	local file = io.open(channel.id..channel.name.."chatlog.txt", "w")
	files[channel.id] = file
	file:write(string.format("Chat log of channel \"%s\" in server \"%s\"\r\nTimestamps correspond to bot's time (GMT+2 by default)\r\n", channel.name, channel.guild.name)
end

function logWriter.finish()

end

return logWriter