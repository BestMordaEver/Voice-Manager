local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

return {
	name = "delete",
	description = "Quickly delete several channels",
	contexts = {contextType.guild},
	options = {
		{
			name = "type",
			description = "Channel type",
			type = commandOptionType.string,
			required = true,
			choices = {
				{
					name = "text",
					value = "text"
				},
				{
					name = "voice",
					value = "voice"
				}
			}
		},
		{
			name = "category",
			description = "Category where channels will be deleted",
			type = commandOptionType.channel,
			channel_types = {
				channelType.category
			}
		},
		{
			name = "amount",
			description = "How many channels to delete",
			type = commandOptionType.integer,
			min_value = 1,
			max_value = 100
		},
		{
			name = "name",
			description = "Delete all the channels that match the name",
			type = commandOptionType.string
		},
		{
			name = "only_empty",
			description = "Whether to delete voice channels with connected users. Defaults to false",
			type = commandOptionType.boolean
		}
	}
}