local enums = require "discordia".enums
local channelType = enums.channelType
local contextType = enums.interactionContextType

local B = require "slash/builders"
local lobbySelect = require "slash/lobbySelect"
local locale = require "locale/localeHandler"

return {
	name = locale.matchmaking,
	description = locale.matchmakingDesc,
	contexts = {contextType.guild},
	options = {
		B.subcommand(locale.view, locale.matchmakingViewDesc, {
			B.channel(locale.lobby, locale.lobbyViewLobbyDesc, {channelType.voice})
		}),

		B.subcommand(locale.add, locale.matchmakingAddDesc, {
			B.channel(locale.channel, locale.lobbyAddChannelDesc, {channelType.voice}, {required = true})
		}),

		B.subcommand(locale.remove, locale.matchmakingRemoveDesc, {
			B.channel(locale.lobby, locale.matchmakingRemoveLobbyDesc, {channelType.voice}, {required = true})
		}),

		B.subcommand(locale.target, locale.matchmakingTargetDesc, {
			lobbySelect,
			B.channel(
				locale.target,
				locale.matchmakingTargetTargetDesc,
				{channelType.voice, channelType.category},
				{required = true}
			)
		}),

		B.subcommand(locale.matchmakingMode, locale.matchmakingModeDesc, {
			lobbySelect,
			B.string(locale.matchmakingMode, locale.matchmakingModeModeDesc, {
				required = true,
				choices = {
					{name = locale.matchmakingModeModeRandom, value = "random"},
					{name = locale.matchmakingModeModeMax,    value = "max"},
					{name = locale.matchmakingModeModeMin,    value = "min"},
					{name = locale.matchmakingModeModeFirst,  value = "first"},
					{name = locale.matchmakingModeModeLast,   value = "last"},
				}
			})
		}),
	}
}