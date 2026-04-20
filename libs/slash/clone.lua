local enums = require "discordia".enums
local channelType = enums.channelType
local contextType = enums.interactionContextType

local B = require "slash/builders"
local locale = require "locale/localeHandler"

return {
	name = locale.clone,
	description = locale.cloneDesc,
	contexts = {contextType.guild},
	options = {
		B.channel(
			locale.cloneSource,
			locale.cloneSourceDesc,
			{channelType.text, channelType.voice},
			{required = true}
		),

		B.integer(
			locale.cloneAmount,
			locale.cloneAmountDesc,
			{required = true, min_value = 1, max_value = 50}
		),

		B.string(
			locale.name,
			locale.cloneNameDesc
		),
	}
}