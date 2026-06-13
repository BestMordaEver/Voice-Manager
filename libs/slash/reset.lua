local contextType = require "discordia".enums.interactionContextType

local B = require "slash/builders"
local lobbySelect = {require "slash/lobbySelect"}
local locale = require "locale/localeHandler"

return {
	name = locale.reset,
	description = locale.resetDesc,
	contexts = {contextType.guild},
	options = {
		B.group(locale.lobby, locale.resetLobbyDesc, {
			B.subcommand(locale.name,             locale.resetLobbyNameDesc,        lobbySelect),
			B.subcommand(locale.category,         locale.resetLobbyCategoryDesc,    lobbySelect),
			B.subcommand(locale.target,           locale.resetLobbyTargetDesc,      lobbySelect),
			B.subcommand(locale.bitrate,          locale.resetLobbyBitrateDesc,     lobbySelect),
			B.subcommand(locale.lobbyCapacity,    locale.resetLobbyCapacityDesc,    lobbySelect),
			B.subcommand(locale.lobbyPermissions, locale.resetLobbyPermissionsDesc, lobbySelect),
			B.subcommand(locale.role,             locale.resetLobbyRoleDesc,        lobbySelect),
			B.subcommand(locale.limit,            locale.resetLobbyLimitDesc,       lobbySelect),
			B.subcommand(locale.lobbyRegion,      locale.resetLobbyRegionDesc,      lobbySelect),
			B.subcommand(locale.lobbyGaps,        locale.resetLobbyGapsDesc,        lobbySelect),
			B.subcommand(locale.lobbyPosition,    locale.resetLobbyPositionDesc,    lobbySelect),
			B.subcommand(locale.lobbyOrder,       locale.resetLobbyOrderDesc,       lobbySelect),
		}),

		B.group(locale.matchmaking, locale.resetMatchmakingDesc, {
			B.subcommand(locale.target,          locale.resetMatchmakingTargetDesc, lobbySelect),
			B.subcommand(locale.matchmakingMode, locale.resetMatchmakingModeDesc,  lobbySelect),
		}),

		B.group(locale.companion, locale.resetCompanionDesc, {
			B.subcommand(locale.category,         locale.resetCompanionCategoryDesc, lobbySelect),
			B.subcommand(locale.name,             locale.resetCompanionNameDesc,     lobbySelect),
			B.subcommand(locale.companionGreeting, locale.resetCompanionGreetingDesc, lobbySelect),
		}),

		B.group(locale.server, locale.resetServerDesc, {
			B.subcommand(locale.limit,            locale.resetServerLimitDesc),
			B.subcommand(locale.lobbyPermissions, locale.resetServerPermissionsDesc),
			B.subcommand(locale.role,             locale.resetLobbyRoleDesc),
		}),
	}
}