local enums = require "discordia".enums
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType
local permissionList = require "slash/permissionList"

return {
	name = "server",
	description = "Configure global server settings",
	contexts = {contextType.guild},
	options = {
		{
			name = "view",
			description = "Show server settings",
			type = commandOptionType.subcommand
		},
		{
			name = "limit",
			description = "Limit the amount of rooms bot is permitted to create",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "limit",
					description = "The amount of rooms bot will be able to create",
					type = commandOptionType.integer,
					required = true,
					min_value = 0,
					max_value = 500
				}
			}
		},
		{
			name = "permissions",
			description = "Give users ability to access room commands in normal channels",
			type = commandOptionType.subcommand,
			options = permissionList
		},
		{
			name = "role",
			description = "Change the default role bot uses to enforce user commands",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "add",
					description = "Add another role to be used",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "role",
							description = "The role to be added",
							type = commandOptionType.role,
							required = true
						}
					}
				},
				{
					name = "remove",
					description = "Remove the role from the managed list",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "role",
							description = "The role to be removed",
							type = commandOptionType.role,
							required = true
						}
					}
				}
			}
		}
	}
}