local commandOptionType = require "discordia".enums.applicationCommandOptionType
local locale = require "locale/localeHandler"

return {
	{
		name = locale.moderate,
		description = locale.moderateDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.manage,
		description = locale.manageDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.rename,
		description = locale.renameDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.resize,
		description = locale.resizeDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.bitrate,
		description = locale.bitrateDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.kick,
		description = locale.kickDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.mute,
		description = locale.muteDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.hide,
		description = locale.hideDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.lock,
		description = locale.lockDesc,
		type = commandOptionType.boolean
	},
	{
		name = locale.password,
		description = locale.passwordDesc,
		type = commandOptionType.boolean
	}
}