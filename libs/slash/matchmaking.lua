local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

---@module "locale/slash/en-US"
local locale = require "locale/localeHandler"

return {
	name = locale.matchmaking,
	description = locale.matchmakingDesc,
	contexts = {contextType.guild},
	options = {
		{
			name = locale.view,
			description = locale.matchmakingViewDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.lobby,
					description = locale.lobbyViewLobbyDesc,
					type = commandOptionType.channel,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = locale.add,
			description = locale.matchmakingAddDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.channel,
					description = locale.lobbyAddChannelDesc,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = locale.remove,
			description = locale.matchmakingRemoveDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.lobby,
					description = locale.matchmakingRemoveLobbyDesc,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = locale.matchmakingTarget,
			description = locale.matchmakingTargetDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.lobby,
					description = locale.lobbyConfigured,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				},
				{
					name = locale.matchmakingTarget,
					description = locale.matchmakingTargetTargetDesc,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice, channelType.category
					}
				}
			}
		},
		{
			name = locale.matchmakingMode,
			description = locale.matchmakingModeDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.lobby,
					description = locale.lobbyConfigured,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				},
				{
					name = locale.matchmakingMode,
					description = locale.matchmakingModeModeDesc,
					type = commandOptionType.string,
					required = true,
					choices = {
						{
							name = locale.matchmakingModeModeRandom,
							value = "random"
						},
						{
							name = locale.matchmakingModeModeMax,
							value = "max"
						},
						{
							name = locale.matchmakingModeModeMin,
							value = "min"
						},
						{
							name = locale.matchmakingModeModeFirst,
							value = "first"
						},
						{
							name = locale.matchmakingModeModeLast,
							value = "last"
						}
					}
				}
			}
		}
	}
}