local contextType = require "discordia".enums.interactionContextType

local B = require "slash/builders"
local permissionList = require "slash/permissionList"
local locale = require "locale/localeHandler"

return {
	name = locale.server,
	description = locale.serverDesc,
	contexts = {contextType.guild},
	options = {
		B.subcommand(locale.view, locale.serverViewDesc),

		B.subcommand(locale.limit, locale.lobbyLimitDesc, {
			B.integer(
				locale.limit,
				locale.lobbyLimitLimitDesc,
				{required = true, min_value = 0, max_value = 500}
			)
		}),

		B.subcommand(locale.lobbyPermissions, locale.serverPermissionsDesc, permissionList),

		B.group(locale.role, locale.lobbyRoleDesc, {
			B.subcommand(locale.add, locale.lobbyRoleAddDesc, {
				B.role(locale.role, locale.lobbyRoleAddRoleDesc, {required = true})
			}),
			B.subcommand(locale.remove, locale.lobbyRoleRemoveDesc, {
				B.role(locale.role, locale.lobbyRoleRemoveRoleDesc, {required = true})
			}),
		}),
	}
}