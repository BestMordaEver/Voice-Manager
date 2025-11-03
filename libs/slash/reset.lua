local enums = require "discordia".enums
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

local lobbySelect = {require "slash/lobbySelect"}
local locale = require "locale/localeHandler"

return {
	name = locale.reset,
	description = locale.resetDesc,
	contexts = {contextType.guild},
	options = {
		{
			name = locale.lobby,
			description = locale.resetLobbyDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.name,
					description = locale.resetLobbyNameDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.category,
					description = locale.resetLobbyCategoryDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.bitrate,
					description = locale.resetLobbyBitrateDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.lobbyCapacity,
					description = locale.resetLobbyCapacityDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.lobbyPermissions,
					description = locale.resetLobbyPermissionsDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.role,
					description = locale.resetLobbyRoleDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.limit,
					description = locale.resetLobbyLimitDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.lobbyRegion,
					description = locale.resetLobbyRegionDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
			}
		},
		{
			name = locale.matchmaking,
			description = locale.resetMatchmakingDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.matchmakingTarget,
					description = locale.resetMatchmakingTargetDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.matchmakingMode,
					description = locale.resetMatchmakingModeDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				}
			}
		},
		{
			name = locale.companion,
			description = locale.resetCompanionDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.category,
					description = locale.resetCompanionCategoryDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.name,
					description = locale.resetCompanionNameDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.companionGreeting,
					description = locale.resetCompanionGreetingDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				},
				{
					name = locale.companionLog,
					description = locale.resetCompanionLogDesc,
					type = commandOptionType.subcommand,
					options = lobbySelect
				}
			}
		},
		{
			name = locale.server,
			description = locale.resetServerDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.limit,
					description = locale.resetServerLimitDesc,
					type = commandOptionType.subcommand
				},
				{
					name = locale.lobbyPermissions,
					description = locale.resetServerPermissionsDesc,
					type = commandOptionType.subcommand
				},
				{
					name = locale.role,
					description = locale.resetLobbyRoleDesc,
					type = commandOptionType.subcommand
				}
			}
		}
	}
}