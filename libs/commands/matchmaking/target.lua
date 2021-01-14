local locale = require "locale"
local lobbies = require "storage/lobbies"
local lookForChannel = require "funcs/lookForChannel"
local permissionsCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

return function (message, channel, input)
	local category = lookForChannel(message, input)	-- could be lobby!
	if not category and not (category.type == channelType.voice and lobbies[category.id]) then 
		message:reply(locale.badChannel)
		return "Couldn't find target"
	end
	
	local isPermitted, msg = permissionsCheck(message, category)
	if isPermitted then
		lobbies[channel.id]:setTarget(category.id)
		message:reply(locale.targetConfirm:format(category.name))
		return "Lobby target category set"
	else
		return msg
	end
end