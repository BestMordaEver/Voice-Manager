local enums = require "discordia".enums
local channelType = enums.channelType
local contextType = enums.interactionContextType

local B = require "slash/builders"
local permissionList = require "slash/permissionList"
local lobbySelect = require "slash/lobbySelect"
local locale = require "locale/localeHandler"

return {
	name = locale.lobby,
	description = locale.lobbyDesc,
	contexts = {contextType.guild},
	options = {
		B.subcommand(locale.view, locale.lobbyViewDesc, {
			B.channel(locale.lobby, locale.lobbyViewLobbyDesc, {channelType.voice})
		}),

		B.subcommand(locale.add, locale.lobbyAddDesc, {
			B.channel(
				locale.channel,
				locale.lobbyAddChannelDesc,
				{channelType.voice},
				{required = true}
			)
		}),

		B.subcommand(locale.remove, locale.lobbyRemoveDesc, {
			B.channel(
				locale.lobby,
				locale.lobbyRemoveLobbyDesc,
				{channelType.voice},
				{required = true}
			)
		}),

		B.subcommand(locale.name, locale.lobbyNameDesc, {
			lobbySelect,
			B.string(locale.name, locale.lobbyNameNameDesc, {required = true})
		}),

		B.subcommand(locale.category, locale.lobbyCategoryDesc, {
			lobbySelect,
			B.channel(
				locale.category,
				locale.lobbyCategoryCategoryDesc,
				{channelType.category},
				{required = true}
			)
		}),

		B.subcommand(locale.target, locale.lobbyCategoryDesc, {
			lobbySelect,
			B.channel(
				locale.target,
				locale.lobbyTargetTargetDesc,
				{channelType.voice},
				{required = true}
			)
		}),

		B.subcommand(locale.bitrate, locale.lobbyBitrateDesc, {
			lobbySelect,
			B.integer(
				locale.bitrate,
				locale.lobbyBitrateBitrateDesc,
				{required = true, min_value = 8, max_value = 384}
			)
		}),

		B.subcommand(locale.lobbyCapacity, locale.lobbyCapacityDesc, {
			lobbySelect,
			B.integer(
				locale.lobbyCapacity,
				locale.lobbyCapacityCapacityDesc,
				{required = true, min_value = 0, max_value = 99}
			)
		}),

		B.subcommand(locale.lobbyPermissions, locale.lobbyPermissionsDesc, {
			lobbySelect,
			table.unpack(permissionList)
		}),

		B.group(locale.role, locale.lobbyRoleDesc, {
			B.subcommand(locale.add, locale.lobbyRoleAddDesc, {
				lobbySelect,
				B.role(locale.role, locale.lobbyRoleAddRoleDesc, {required = true})
			}),
			B.subcommand(locale.remove, locale.lobbyRoleRemoveDesc, {
				lobbySelect,
				B.role(locale.role, locale.lobbyRoleRemoveRoleDesc, {required = true})
			}),
		}),

		B.subcommand(locale.limit, locale.lobbyLimitDesc, {
			lobbySelect,
			B.integer(
				locale.limit,
				locale.lobbyLimitLimitDesc,
				{required = true, min_value = 0, max_value = 500}
			)
		}),

		B.subcommand(locale.lobbyRegion, locale.lobbyRegionDesc, {lobbySelect}),

		B.subcommand(locale.lobbyGaps, locale.lobbyGapsDesc, {
			lobbySelect,
			B.boolean(locale.lobbyGapsFill, locale.lobbyGapsFillDesc, {required = true})
		}),

		B.subcommand(locale.lobbyPosition, locale.lobbyPositionDesc, {
			lobbySelect,
			B.string(locale.lobbyPosition, locale.lobbyPositionPositionDesc, {
				required = true,
				choices = {
					{name = locale.lobbyPositionAbove, value = "above"},
					{name = locale.lobbyPositionBelow, value = "below"},
				}
			})
		}),

		B.subcommand(locale.lobbyOrder, locale.lobbyOrderDesc, {
			lobbySelect,
			B.string(locale.lobbyOrder, locale.lobbyOrderOrderDesc, {
				required = true,
				choices = {
					{name = locale.lobbyOrderAscending,  value = "ascending"},
					{name = locale.lobbyOrderDescending, value = "descending"},
				}
			})
		}),
	}
}