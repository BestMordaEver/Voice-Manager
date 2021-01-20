local locale = require "locale"
local lobbies = require "storage/lobbies"
local lookForChannel = require "funcs/lookForChannel"
local permissionsCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

return function (message, channel, input)
	local category = lookForChannel(message, input)
	if not category or category.type ~= channelType.category then
		return "Couldn't find target category", "warning", locale.badCategory
	end
	
	local isPermitted, logMsg, msg = permissionsCheck(message, category)
	if isPermitted then
		lobbies[channel.id]:setTarget(category.id)
		return "Lobby target category set", "ok", locale.categoryConfirm:format(category.name)
	else
		return logMsg, "warning", msg
	end
end