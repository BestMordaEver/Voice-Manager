local enums = require "discordia".enums
local channelType = enums.channelType
local contextType = enums.interactionContextType

local B = require "slash/builders"
local lobbySelect = require "slash/lobbySelect"
local locale = require "locale/localeHandler"

return {
	name = locale.logging,
	description = locale.loggingDesc,
	contexts = {contextType.guild},
	options = {
		B.subcommand(locale.view, locale.loggingViewDesc, {
			B.channel(locale.lobby, locale.lobbyViewLobbyDesc, {channelType.voice})
		}),

		B.subcommand(locale.enable, locale.loggingEnableDesc, {
			lobbySelect,
			B.channel(
				locale.channel,
				locale.loggingChannelChannelDesc,
				{channelType.text},
				{required = true}
			)
		}),

		B.subcommand(locale.disable, locale.loggingDisableDesc, {lobbySelect}),

		B.subcommand(locale.channel, locale.loggingChannelDesc, {
			lobbySelect,
			B.channel(
				locale.channel,
				locale.loggingChannelChannelDesc,
				{channelType.text},
				{required = true}
			)
		}),

		B.subcommand(locale.loggingOffset, locale.loggingOffsetDesc, {
			B.string(
				locale.loggingOffset,
				locale.loggingOffsetOffsetDesc,
				{required = true}
			)
		}),
	}
}
