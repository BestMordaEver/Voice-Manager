local enums = require "discordia".enums
local channelType = enums.channelType
local contextType = enums.interactionContextType

local B = require "slash/builders"
local lobbySelect = require "slash/lobbySelect"
local locale = require "locale/localeHandler"

return {
	name = locale.companion,
	description = locale.companionDesc,
	contexts = {contextType.guild},
	options = {
		B.subcommand(locale.view, locale.companionViewDesc, {
			B.channel(locale.lobby, locale.lobbyViewLobbyDesc, {channelType.voice})
		}),

		B.subcommand(locale.enable, locale.companionEnableDesc, {lobbySelect}),
		B.subcommand(locale.disable, locale.companionDisableDesc, {lobbySelect}),

		B.subcommand(locale.category, locale.companionCategoryDesc, {
			lobbySelect,
			B.channel(
				locale.category,
				locale.companionCategoryCategoryDesc,
				{channelType.category},
				{required = true}
			)
		}),

		B.subcommand(locale.name, locale.companionNameDesc, {
			lobbySelect,
			B.string(locale.name, locale.companionNameNameDesc, {required = true})
		}),

		B.subcommand(locale.companionGreeting, locale.companionGreetingDesc, {
			lobbySelect,
			B.string(locale.companionGreeting, locale.companionGreetingGreetingDesc)
		}),

		B.subcommand(locale.companionLog, locale.companionLogDesc, {
			lobbySelect,
			B.channel(
				locale.channel,
				locale.companionLogChannelDesc,
				{channelType.text},
				{required = true}
			)
		}),
	}
}