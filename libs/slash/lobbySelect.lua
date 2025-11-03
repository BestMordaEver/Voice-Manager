local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType

local locale = require "locale/localeHandler"

return {
	name = locale.lobby,
	description = locale.lobbyConfigured,
	type = commandOptionType.channel,
	required = true,
	channel_types = {
		channelType.voice
	}
}