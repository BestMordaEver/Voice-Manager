local locale = require "locale"
local lobbies = require "storage/lobbies"
local lookForChannel = require "funcs/lookForChannel"
local permissionsCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

return function (message, channel, input)
	local category = lookForChannel(message, input)	-- could be lobby!
	if not category and not (category.type == channelType.voice and lobbies[category.id]) then 
		return "Couldn't find target", "warning", locale.badChannel
	end
	
	local isPermitted, logMsg, msg = permissionsCheck(message, category)
	if isPermitted then
		lobbies[channel.id]:setTarget(category.id)
		return "Lobby target category set", "ok", locale.targetConfirm:format(category.name)
	else
		return logMsg, "warning", msg
	end
end