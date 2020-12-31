local client = require "client"
local logger = require "logger"
local locale = require "locale"
local Dialogue = require "utils/dialogue"
local lookForChannel = require "funcs/lookForChannel"
local channelType = require "discordia".enums.channelType

return function (message)
	local dialogue = Dialogue(message.author.id, message.guild)
	local channel = lookForChannel(message.content:match("select%s*(.-)$"))
	
	if channel then
		dialogue.selected = channel.id
		if channel.type = channelType.voice then
			message:reply(locale.selectVoice)
			return "Selected voice channel "..channel.id
		else
			message:reply(locale.selectCategory)
			return "Selected category "..channel.id
		end
	else
		message:reply(locale.selectFailed)
		return "Selected nothing"
	end
end