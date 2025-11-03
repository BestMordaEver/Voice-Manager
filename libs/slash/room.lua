local commandOptionType = require "discordia".enums.applicationCommandOptionType

---@module "locale/slash/en-US"
local locale = require "locale/localeHandler"

return {
	name = locale.room,
	description = locale.roomDesc,
	options = {
		{
			name = locale.view,
			description = locale.roomViewDesc,
			type = commandOptionType.subcommand
		},
		{
			name = locale.roomHost,
			description = locale.roomHostDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.roomHostUser,
					description = locale.roomHostUserDesc,
					type = commandOptionType.user
				}
			}
		},
		{
			name = locale.roomInvite,
			description = locale.roomInviteDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.roomHostUser,
					description = locale.roomInviteUserDesc,
					type = commandOptionType.user
				}
			}
		},
		{
			name = locale.rename,
			description = locale.roomRenameDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.voice,
					description = locale.roomRenameVoiceDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.name,
							description = locale.roomRenameVoiceNameDesc,
							type = commandOptionType.string,
							required = true
						}
					}
				},
				{
					name = locale.text,
					description = locale.roomRenameTextDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.name,
							description = locale.roomRenameTextNameDesc,
							type = commandOptionType.string,
							required = true
						}
					}
				}
			}
		},
		{
			name = locale.resize,
			description = locale.roomResizeDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.lobbyCapacity,
					description = locale.roomResizeCapacityDesc,
					type = commandOptionType.integer,
					min_value = 0,
					max_value = 99,
					required = true
				}
			}
		},
		{
			name = locale.bitrate,
			description = locale.roomBitrateDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.bitrate,
					description = locale.roomBitrateBitrateDesc,
					type = commandOptionType.integer,
					min_value = 8,
					max_value = 384,
					required = true
				}
			}
		},
		{
			name = locale.kick,
			description = locale.roomKickDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.roomHostUser,
					description = locale.roomKickUserDesc,
					type = commandOptionType.user,
					required = true
				}
			}
		},
		{
			name = locale.mute,
			description = locale.roomMuteDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.voice,
					description = locale.roomMuteVoiceDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomMuteBothUserDesc,
							type = commandOptionType.user
						}
					}
				},
				{
					name = locale.text,
					description = locale.roomMuteTextDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomMuteBothUserDesc,
							type = commandOptionType.user
						}
					}
				},
				{
					name = locale.roomMuteBoth,
					description = locale.roomMuteBothDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomMuteBothUserDesc,
							type = commandOptionType.user
						}
					}
				}
			}
		},
		{
			name = locale.roomUnmute,
			description = locale.roomUnmuteDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.voice,
					description = locale.roomUnmuteVoiceDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomUnmuteTextUserDesc,
							type = commandOptionType.user
						}
					}
				},
				{
					name = locale.text,
					description = locale.roomUnmuteTextDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomUnmuteTextUserDesc,
							type = commandOptionType.user
						}
					}
				},
				{
					name = locale.roomMuteBoth,
					description = locale.roomUnmuteBothDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomUnmuteTextUserDesc,
							type = commandOptionType.user
						}
					}
				}
			}
		},
		{
			name = locale.hide,
			description = locale.roomHideDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.voice,
					description = locale.roomHideVoiceDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomHideTextUserDesc,
							type = commandOptionType.user
						}
					}
				},
				{
					name = locale.text,
					description = locale.roomHideTextDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomHideTextUserDesc,
							type = commandOptionType.user
						}
					}
				},
				{
					name = locale.roomMuteBoth,
					description = locale.roomHideBothDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomHideBothUserDesc,
							type = commandOptionType.user
						}
					}
				}
			}
		},
		{
			name = locale.roomShow,
			description = locale.roomShowDesc,
			type = commandOptionType.subcommandGroup,
			options = {
				{
					name = locale.voice,
					description = locale.roomShowVoiceDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomShowTextUserDesc,
							type = commandOptionType.user
						}
					}
				},
				{
					name = locale.text,
					description = locale.roomShowTextDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomShowTextUserDesc,
							type = commandOptionType.user
						}
					}
				},
				{
					name = locale.roomMuteBoth,
					description = locale.roomShowBothDesc,
					type = commandOptionType.subcommand,
					options = {
						{
							name = locale.roomHostUser,
							description = locale.roomShowBothUserDesc,
							type = commandOptionType.user
						}
					}
				}
			}
		},
		{
			name = locale.roomBlock,
			description = locale.roomBlockDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.roomHostUser,
					description = locale.roomBlockUserDesc,
					type = commandOptionType.user,
					required = true
				}
			}
		},
		{
			name = locale.roomAllow,
			description = locale.roomAllowDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.roomHostUser,
					description = locale.roomAllowUserDesc,
					type = commandOptionType.user,
					required = true
				}
			}
		},
		{
			name = locale.lock,
			description = locale.roomLockDesc,
			type = commandOptionType.subcommand
		},
		{
			name = locale.roomUnlock,
			description = locale.roomUnlockDesc,
			type = commandOptionType.subcommand
		},
		{
			name = locale.password,
			description = locale.roomPasswordDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.password,
					description = locale.roomPasswordPasswordDesc,
					type = commandOptionType.string
				}
			}
		}
	}
}