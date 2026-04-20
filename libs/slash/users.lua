local enums = require "discordia".enums
local channelType = enums.channelType
local contextType = enums.interactionContextType

local B = require "slash/builders"
local locale = require "locale/localeHandler"

local channel_types = {
	channelType.voice,
	channelType.stageVoice,
	channelType.category
}

return {
	name = locale.users,
	description = locale.usersDesc,
	contexts = {contextType.guild},
	options = {
		B.subcommand(locale.usersPrint, locale.usersPrintDesc, {
			B.channel(
				locale.channel,
				locale.usersPrintChannelDesc,
				channel_types,
				{required = true}
			),
			B.string(locale.usersPrintPrint_as, locale.usersPrintPrint_asDesc, {
				choices = {
					{name = locale.usersPrintPrint_asUsername, value = "username"},
					{name = locale.usersPrintPrint_asTag,      value = "tag"},
					{name = locale.usersPrintPrint_asNickname, value = "nickname"},
					{name = locale.usersPrintPrint_asMention,  value = "mention"},
					{name = locale.usersPrintPrint_asId,       value = "id"},
				}
			}),
			B.string(locale.usersPrintSeparator, locale.usersPrintSeparatorDesc),
		}),

		B.subcommand(locale.usersGive, locale.usersGiveDesc, {
			B.channel(
				locale.channel,
				locale.usersGiveChannelDesc,
				channel_types,
				{required = true}
			),
			B.role(locale.role, locale.usersGiveRoleDesc, {required = true}),
		}),

		B.subcommand(locale.remove, locale.usersGiveDesc, {
			B.channel(
				locale.channel,
				locale.usersGiveChannelDesc,
				channel_types,
				{required = true}
			),
			B.role(locale.role, locale.usersGiveRoleDesc, {required = true}),
		}),
	}
}