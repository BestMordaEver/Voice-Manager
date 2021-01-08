local locale = require "locale"
local dialogue = require "utils/dialogue"
local lookForChannel = require "funcs/lookForChannel"
local permissionsCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

return function (message)
	local argument = message.content:match("select%s*(.-)$")
	if argument == "" then
		commandHelpEmbed(message, "select")
		return "Sent help for select"
	end
	
	local channel = lookForChannel(message, argument)
	
	if channel then
		local isPermitted, msg = permissionsCheck(message, channel)
		if isPermitted then
			dialogue(message.author.id, channel.id)
			if channel.type == channelType.voice then
				message:reply(locale.selectVoice:format(channel.name))
				return "Selected voice channel "..channel.id
			else
				message:reply(locale.selectCategory:format(channel.name))
				return "Selected category "..channel.id
			end
		else
			return msg
		end
	else
		message:reply(locale.selectFailed)
		return "Selected nothing"
	end
end