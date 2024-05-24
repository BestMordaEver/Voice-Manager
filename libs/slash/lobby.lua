local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType
local permissionList = require "slash/permissionList"

return {
	name = "lobby",
	description = "Configure lobby settings",
	contexts = {contextType.guild},
	options = {
		{
			name = "view",
			description = "Show registered lobbies",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A lobby to be viewed",
					type = commandOptionType.channel,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = "add",
			description = "Register a new lobby",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "channel",
					description = "A channel to be registered",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = "remove",
			description = "Remove an existing lobby",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A lobby to be removed",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = "name",
			description = "Configure what name a room will have when it's created",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A lobby to be configured",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				},
				{
					name = "name",
					description = "Name a room will have when it's created",
					type = commandOptionType.string,
					required = true
				}
			}
		},
		{
			name = "category",
			description = "Select a category in which rooms will be created",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A lobby to be configured",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				},
				{
					name = "category",
					description = "Category in which rooms will be created",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.category
					}
				}
			}
		},
		{
			name = "bitrate",
			description = "Select new rooms' bitrate",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A lobby to be configured",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				},
				{
					name = "bitrate",
					description = "New rooms' bitrate",
					type = commandOptionType.integer,
					required = true,
					min_value = 8,
					max_value = 384
				}
			}
		},
		{
			name = "capacity",
			description = "Select new rooms' capacity",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A lobby to be configured",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				},
				{
					name = "capacity",
					description = "New rooms' capacity",
					type = commandOptionType.integer,
					required = true,
					min_value = 0,
					max_value = 99
				}
			}
		},
		{
			name = "permissions",
			description = "Give room hosts' access to different commands",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A lobby to be configured",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				},
				table.unpack(permissionList)
			}
		},
		--[[{
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
							name = "lobby",
							description = "A lobby to be configured",
							type = commandOptionType.channel,
							required = true,
							channel_types = {
								channelType.voice
							}
						},
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
							name = "lobby",
							description = "A lobby to be configured",
							type = commandOptionType.channel,
							required = true,
							channel_types = {
								channelType.voice
							}
						},
						{
							name = "role",
							description = "The role to be removed",
							type = commandOptionType.role,
							required = true
						}
					}
				}
			}
		}]]
		{
			name = "role",
			description = "Change the default role bot uses to enforce user commands",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A lobby to be configured",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				},
				{
					name = "role",
					description = "The role to be used",
					type = commandOptionType.role,
					required = true
				}
			}
		}
	}
}