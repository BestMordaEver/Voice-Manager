local locale = require "locale"
local lobbies = require "storage/lobbies"
local dialogue = require "utils/dialogue"
local lookForChannel = require "funcs/lookForChannel"
local permissionCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

return function (message)
	local argument = message.content:match("select%s*(.-)$")
	
	local channel = lookForChannel(message, argument)
	
	if channel then
		local isPermitted, logMsg, msg = permissionCheck(message, channel)
		if not isPermitted then
			return logMsg, "warning", msg
		end
		
		dialogue(message.author.id, channel.id)
		if channel.type == channelType.voice then
			if lobbies[channel.id] then
				return "Selected lobby "..channel.id, "ok", locale.selectVoice:format(channel.name)
			end
		else
			return "Selected category "..channel.id, "ok", locale.selectCategory:format(channel.name)
		end
	end

	return "Selected nothing", "warning", locale.selectFailed
end