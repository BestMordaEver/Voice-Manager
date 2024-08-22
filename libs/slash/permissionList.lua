local commandOptionType = require "discordia".enums.applicationCommandOptionType

return {
	{
		name = "moderate",
		description = "Access to all moderation tools",
		type = commandOptionType.boolean
	},
	{
		name = "manage",
		description = "Access to all room settings",
		type = commandOptionType.boolean
	},
	{
		name = "rename",
		description = "Access to /room rename",
		type = commandOptionType.boolean
	},
	{
		name = "resize",
		description = "Access to /room resize",
		type = commandOptionType.boolean
	},
	{
		name = "bitrate",
		description = "Access to /room bitrate",
		type = commandOptionType.boolean
	},
	{
		name = "kick",
		description = 'Access to /room kick and "Move Members" permission',
		type = commandOptionType.boolean
	},
	{
		name = "mute",
		description = "Access to /room mute|unmute",
		type = commandOptionType.boolean
	},
	{
		name = "hide",
		description = "Access to /room hide|show",
		type = commandOptionType.boolean
	},
	{
		name = "lock",
		description = "Access to /room lock|unlock and /room block|allow",
		type = commandOptionType.boolean
	},
	{
		name = "password",
		description = "Access to /room password",
		type = commandOptionType.boolean
	}
}