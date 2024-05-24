local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

return {
	name = "clone",
	description = "Spawn multiple clones of a channel",
	contexts = {contextType.guild},
	options = {
		{
			name = "source",
			description = "Which channel to copy",
			type = commandOptionType.channel,
			required = true,
			channel_types = {
				channelType.text,
				channelType.voice
			}
		},
		{
			name = "amount",
			description = "How many channels to create",
			type = commandOptionType.integer,
			required = true,
			min_value = 1,
			max_value = 50
		},
		{
			name = "name",
			description = "Channel names",
			type = commandOptionType.string
		}
	}
}