local locale = require "locale"
local lobbies = require "storage/lobbies"
local lookForChannel = require "funcs/lookForChannel"
local permissionsCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

return function (message, channel, input)
	local category = lookForChannel(message, input)
	if not category or category.type ~= channelType.category then 
		message:reply(locale.badCategory)
		return "Couldn't find target category"
	end
	
	local isPermitted, msg = permissionsCheck(message, category)
	if isPermitted then
		lobbies[channel.id]:setCompanionTarget(category.id)
		message:reply(locale.categoryConfirm:format(category.name))
		return "Companion target category set"
	else
		return msg
	end
end