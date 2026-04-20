local B = require "slash/builders"
local locale = require "locale/localeHandler"

return {
	B.boolean(locale.moderate, locale.moderateDesc),
	B.boolean(locale.manage,   locale.manageDesc),
	B.boolean(locale.rename,   locale.renameDesc),
	B.boolean(locale.resize,   locale.resizeDesc),
	B.boolean(locale.bitrate,  locale.bitrateDesc),
	B.boolean(locale.kick,     locale.kickDesc),
	B.boolean(locale.mute,     locale.muteDesc),
	B.boolean(locale.hide,     locale.hideDesc),
	B.boolean(locale.lock,     locale.lockDesc),
	B.boolean(locale.password, locale.passwordDesc),
}