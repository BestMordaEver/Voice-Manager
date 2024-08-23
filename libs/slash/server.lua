local enums = require "discordia".enums
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

local permissionList = require "slash/permissionList"
---@module "locale/slash/en-US"
local locale = require "locale/slash/localeHandler"

return {
	name = locale.server,
	description = locale.serverDesc,
	contexts = {contextType.guild},
	options = {
		{
			name = locale.view,
			description = locale.serverViewDesc,
			type = commandOptionType.subcommand
		},
		{
			name = locale.limit,
			description = locale.lobbyLimitDesc,
			type = commandOptionType.subcommand,
			options = {
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
			name = locale.lobbyPermissions,
			description = locale.serverPermissionsDesc,
			type = commandOptionType.subcommand,
			options = permissionList
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
							name = locale.role,
							description = locale.lobbyRoleRemoveRoleDesc,
							type = commandOptionType.role,
							required = true
						}
					}
				}
			}
		}
	}
}