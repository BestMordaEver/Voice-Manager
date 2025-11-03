local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

---@module "locale/slash/en-US"
local locale = require "locale/localeHandler"

return {
	name = locale.delete,
	description = locale.deleteDesc,
	contexts = {contextType.guild},
	options = {
		{
			name = locale.deleteType,
			description = locale.deleteTypeDesc,
			type = commandOptionType.string,
			required = true,
			choices = {
				{
					name = locale.text,
					value = "text"
				},
				{
					name = locale.voice,
					value = "voice"
				}
			}
		},
		{
			name = locale.category,
			description = locale.deleteCategoryDesc,
			type = commandOptionType.channel,
			channel_types = {
				channelType.category
			}
		},
		{
			name = locale.cloneAmount,
			description = locale.deleteAmountDesc,
			type = commandOptionType.integer,
			min_value = 1,
			max_value = 100
		},
		{
			name = locale.name,
			description = locale.deleteNameDesc,
			type = commandOptionType.string
		},
		{
			name = locale.deleteOnly_empty,
			description = locale.deleteOnly_emptyDesc,
			type = commandOptionType.boolean
		}
	}
}