local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

local locale = require "locale/localeHandler"

return {
	name = locale.clone,
	description = locale.cloneDesc,
	contexts = {contextType.guild},
	options = {
		{
			name = locale.cloneSource,
			description = locale.cloneSourceDesc,
			type = commandOptionType.channel,
			required = true,
			channel_types = {
				channelType.text,
				channelType.voice
			}
		},
		{
			name = locale.cloneAmount,
			description = locale.cloneAmountDesc,
			type = commandOptionType.integer,
			required = true,
			min_value = 1,
			max_value = 50
		},
		{
			name = locale.name,
			description = locale.cloneNameDesc,
			type = commandOptionType.string
		}
	}
}