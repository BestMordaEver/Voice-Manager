local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

local permissionList = require "slash/permissionList"
---@module "locale/slash/en-US"
local locale = require "locale/slash/localeHandler"

return {
	name = locale.lobby,
	description = locale.lobbyDesc,
	contexts = {contextType.guild},
	options = {
		{
			name = locale.view,
			description = locale.lobbyViewDesc,
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
			description = locale.lobbyAddDesc,
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
			description = locale.lobbyRemoveDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.lobby,
					description = locale.lobbyRemoveLobbyDesc,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = locale.name,
			description = locale.lobbyNameDesc,
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
					name = locale.name,
					description = locale.lobbyNameNameDesc,
					type = commandOptionType.string,
					required = true
				}
			}
		},
		{
			name = locale.category,
			description = locale.lobbyCategoryDesc,
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
					name = locale.category,
					description = locale.lobbyCategoryCategoryDesc,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.category
					}
				}
			}
		},
		{
			name = locale.bitrate,
			description = locale.lobbyBitrateDesc,
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
					name = locale.bitrate,
					description = locale.lobbyBitrateBitrateDesc,
					type = commandOptionType.integer,
					required = true,
					min_value = 8,
					max_value = 384
				}
			}
		},
		{
			name = locale.lobbyCapacity,
			description = locale.lobbyCapacityDesc,
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
					name = locale.lobbyCapacity,
					description = locale.lobbyCapacityCapacityDesc,
					type = commandOptionType.integer,
					required = true,
					min_value = 0,
					max_value = 99
				}
			}
		},
		{
			name = locale.lobbyPermissions,
			description = locale.lobbyPermissionsDesc,
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
				table.unpack(permissionList)
			}
		},
		{
			name = locale.role,
			description = locale.lobbyRoleDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.add,
					description = locale.lobbyRoleAddDesc,
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
							name = locale.role,
							description = locale.lobbyRoleAddRoleDesc,
							type = commandOptionType.role,
							required = true
						}
					}
				},
				{
					name = locale.remove,
					description = locale.lobbyRoleRemoveDesc,
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
							name = locale.role,
							description = locale.lobbyRoleRemoveRoleDesc,
							type = commandOptionType.role,
							required = true
						}
					}
				}
			}
		},
		{
			name = locale.limit,
			description = locale.lobbyLimitDesc,
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
					name = locale.limit,
					description = locale.lobbyLimitLimitDesc,
					type = commandOptionType.integer,
					required = true,
					min_value = 0,
					max_value = 500
				}
			}
		},
		{
			name = locale.lobbyRegion,
			description = locale.lobbyRegionDesc,
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
				}
			}
		},
	}
}