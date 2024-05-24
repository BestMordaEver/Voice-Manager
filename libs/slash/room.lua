local enums = require "discordia".enums
local commandOptionType = enums.applicationCommandOptionType

return {
	name = "room",
	description = "Configure room settings",
	options = {
		{
			name = "view",
			description = "Show room settings",
			type = commandOptionType.subcommand
		},
		{
			name = "host",
			description = "Ping current room host and transfer room ownership",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "user",
					description = "User that you want to transfer ownership to",
					type = commandOptionType.user
				}
			}
		},
		{
			name = "invite",
			description = "Send people an invite to immediately connect to the room",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "user",
					description = "User that you want to send an invite to",
					type = commandOptionType.user
				}
			}
		},
		{
			name = "rename",
			description = "Change the name of the room",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "voice",
					description = "Change the name of the voice channel",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "name",
							description = "New voice channel name",
							type = commandOptionType.string,
							required = true
						}
					}
				},
				{
					name = "text",
					description = "Change the name of the companion text channel, if there is one",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "name",
							description = "New text channel name",
							type = commandOptionType.string,
							required = true
						}
					}
				}
			}
		},
		{
			name = "resize",
			description = "Change the capacity of the room",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "capacity",
					description = "New room capacity",
					type = commandOptionType.integer,
					min_value = 0,
					max_value = 99,
					required = true
				}
			}
		},
		{
			name = "bitrate",
			description = "Change the bitrate",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "bitrate",
					description = "New room bitrate",
					type = commandOptionType.integer,
					min_value = 8,
					max_value = 384,
					required = true
				}
			}
		},
		{
			name = "kick",
			description = "Kick a user from your room",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "user",
					description = "User that you want to kick",
					type = commandOptionType.user,
					required = true
				}
			}
		},
		{
			name = "mute",
			description = "Mute newly connected users",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "voice",
					description = "Prevent the new users from speaking in this voice chat",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Mute a specific user",
							type = commandOptionType.user
						}
					}
				},
				{
					name = "text",
					description = "Prevent the new users from typing in the text chat",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Mute a specific user",
							type = commandOptionType.user
						}
					}
				},
				{
					name = "both",
					description = "Prevent the new users to both write and speak in this room",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Mute a specific user",
							type = commandOptionType.user
						}
					}
				}
			}
		},
		{
			name = "unmute",
			description = "Allow the newly connected users to speak",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "voice",
					description = "Allow the new users to speak",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Unmute a specific user",
							type = commandOptionType.user
						}
					}
				},
				{
					name = "text",
					description = "Allow the new users to type in the text chat",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Unmute a specific user",
							type = commandOptionType.user
						}
					}
				},
				{
					name = "both",
					description = "Allow the new users to write and speak in this room",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Unmute a specific user",
							type = commandOptionType.user
						}
					}
				}
			}
		},
		{
			name = "hide",
			description = "Hide the room",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "voice",
					description = "Hide only the voice channel",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Hide the channel from a specific user",
							type = commandOptionType.user
						}
					}
				},
				{
					name = "text",
					description = "Hide only the text channel",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Hide the channel from a specific user",
							type = commandOptionType.user
						}
					}
				},
				{
					name = "both",
					description = "Hide all the channels relevant to the room",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Hide the channels from a specific user",
							type = commandOptionType.user
						}
					}
				}
			}
		},
		{
			name = "show",
			description = "Make the room visible",
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = "voice",
					description = "Reveal only the voice channel",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Reveal the channel to a specific user",
							type = commandOptionType.user
						}
					}
				},
				{
					name = "text",
					description = "Reveal only the text channel",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Reveal the channel to a specific user",
							type = commandOptionType.user
						}
					}
				},
				{
					name = "both",
					description = "Reveal all the channels relevant to the room",
					type = commandOptionType.subcommand,
					options = {
						{
							name = "user",
							description = "Reveal the channels to a specific user",
							type = commandOptionType.user
						}
					}
				}
			}
		},
		{
			name = "block",
			description = "Prevent the user from connecting to the room",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "user",
					description = "User that you want to block",
					type = commandOptionType.user,
					required = true
				}
			}
		},
		{
			name = "unblock",
			description = "Allow the user to connect to the room",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "user",
					description = "User that you want to unblock",
					type = commandOptionType.user,
					required = true
				}
			}
		},
		{
			name = "lock",
			description = "Set the room to invite only mode",
			type = commandOptionType.subcommand
		},
		{
			name = "unlock",
			description = "Make the room public",
			type = commandOptionType.subcommand
		},
		{
			name = "password",
			description = "Set up a channel password",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "password",
					description = "Password that users will have to enter upon connection",
					type = commandOptionType.string
				}
			}
		}
	}
}