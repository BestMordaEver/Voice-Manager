local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

return {
	name = "reset",
	description = "Reset bot settings",
	contexts = {contextType.guild},
	options = {
		{
			name = "lobby",
			description = "Lobby settings",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "name",
					description = "Set new room name to default \"%nickname's room\"",
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
						}
					}
				},
				{
					name = "category",
					description = "Set new room category to lobby's category",
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
						}
					}
				},
				{
					name = "bitrate",
					description = "Set new room bitrate to 64",
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
						}
					}
				},
				{
					name = "capacity",
					description = "Set new room capacity to copy from lobby",
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
						}
					}
				},
				{
					name = "permissions",
					description = "Disable all room permissions",
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
						}
					}
				},
				{
					name = "role",
					description = "Reset default managed role to @everyone",
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
						}
					}
				},
				{
					name = "limit",
					description = "Reset the limit to 500",
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
						}
					}
				},
			}
		},
		{
			name = "matchmaking",
			description = "Matchmaking lobby settings",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "target",
					description = "Reset matchmaking target to current category",
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
						}
					}
				},
				{
					name = "mode",
					description = "Reset matchmaking mode to random",
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
						}
					}
				}
			}
		},
		{
			name = "companion",
			description = "Lobby companion settings",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "category",
					description = "Reset companion category to use lobby settings",
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
						}
					}
				},
				{
					name = "name",
					description = "Reset companion name to \"private-chat\"",
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
						}
					}
				},
				{
					name = "greeting",
					description = "Disable companion greeting",
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
						}
					}
				},
				{
					name = "log",
					description = "Disable companion logging",
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
						}
					}
				}
			}
		},
		{
			name = "server",
			description = "Server settings",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "limit",
					description = "Reset limit to 500",
					type = commandOptionType.subcommand
				},
				{
					name = "permissions",
					description = "Disable all permissions",
					type = commandOptionType.subcommand
				},
				{
					name = "role",
					description = "Reset default managed role to @everyone",
					type = commandOptionType.subcommand
				}
			}
		}
	}
}