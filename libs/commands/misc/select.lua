local locale = require "locale"
local dialogue = require "utils/dialogue"
local lookForChannel = require "funcs/lookForChannel"
local permissionCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

return function (message)
	local argument = message.content:match("select%s*(.-)$")
	
	local channel = lookForChannel(message, argument)
	
	if channel then
		local isPermitted, logMsg, msg = permissionCheck(message, channel)
		if isPermitted then
			dialogue(message.author.id, channel.id)
			if channel.type == channelType.voice then
				return "Selected voice channel "..channel.id, "ok", locale.selectVoice:format(channel.name)
			else
				return "Selected category "..channel.id, "ok", locale.selectCategory:format(channel.name)
			end
		else
			return logMsg, "warning", msg
		end
	else
		return "Selected nothing", "warning", locale.selectFailed
	end
end