local locale = require "locale"
local lobbies = require "storage/lobbies"
local lookForChannel = require "funcs/lookForChannel"
local permissionCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

return function (message, channel, input)
	if input then
		local logChannel = lookForChannel(message, input)
		if not logChannel or logChannel.type ~= channelType.text then
			return "Couldn't find the channel", "warning", locale.badChannel
		end
		
		local isPermitted, logMsg, msg = permissionCheck(message, logChannel)
		if isPermitted then
			lobbies[channel.id]:setCompanionLog(logChannel.id)
			return "Companion log channel set", "ok", locale.logConfirm:format(logChannel.name)
		else
			return logMsg, "warning", msg
		end
	else
		lobbies[channel.id]:setCompanionLog()
		return "Companion log channel reset", "ok", locale.logReset
	end
end
