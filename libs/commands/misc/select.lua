local client = require "client"
local logger = require "logger"
local locale = require "locale"
local Dialogue = require "utils/dialogue"
local commandHelpEmbed = require "embeds/commandHelp"
local lookForChannel = require "funcs/lookForChannel"
local channelType = require "discordia".enums.channelType

return function (message)
	local argument = message.content:match("select%s*(.-)$")
	if argument == "" then
		commandHelpEmbed(message, "select")
		return "Sent help for select"
	end
	
	local channel = lookForChannel(argument)
	
	if channel then
		Dialogue(message.author.id, channel.id)
		if channel.type == channelType.voice then
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