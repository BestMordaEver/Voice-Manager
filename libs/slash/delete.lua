local enums = require "discordia".enums
local channelType = enums.channelType
local contextType = enums.interactionContextType

local B = require "slash/builders"
local locale = require "locale/localeHandler"

return {
	name = locale.delete,
	description = locale.deleteDesc,
	contexts = {contextType.guild},
	options = {
		B.string(locale.deleteType, locale.deleteTypeDesc, {
			required = true,
			choices = {
				{name = locale.text,  value = "text"},
				{name = locale.voice, value = "voice"},
			}
		}),

		B.channel(
			locale.category,
			locale.deleteCategoryDesc,
			{channelType.category}
		),

		B.integer(
			locale.cloneAmount,
			locale.deleteAmountDesc,
			{min_value = 1, max_value = 100}
		),

		B.string(locale.name, locale.deleteNameDesc),
		B.boolean(locale.deleteOnly_empty, locale.deleteOnly_emptyDesc),
	}
}