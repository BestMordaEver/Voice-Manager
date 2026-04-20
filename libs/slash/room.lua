local B = require "slash/builders"
local locale = require "locale/localeHandler"

local function voiceTextBothGroup(name, desc, voiceDesc, textDesc, bothDesc, userDesc, bothUserDesc)
	return B.group(name, desc, {
		B.subcommand(locale.voice,        voiceDesc, { B.user(locale.roomHostUser, userDesc) }),
		B.subcommand(locale.text,         textDesc,  { B.user(locale.roomHostUser, userDesc) }),
		B.subcommand(locale.roomMuteBoth, bothDesc,  { B.user(locale.roomHostUser, bothUserDesc or userDesc) }),
	})
end

return {
	name = locale.room,
	description = locale.roomDesc,
	options = {
		B.subcommand(locale.view, locale.roomViewDesc),

		B.subcommand(locale.roomHost, locale.roomHostDesc, {
			B.user(locale.roomHostUser, locale.roomHostUserDesc)
		}),

		B.subcommand(locale.roomInvite, locale.roomInviteDesc, {
			B.user(locale.roomHostUser, locale.roomInviteUserDesc)
		}),

		B.group(locale.rename, locale.roomRenameDesc, {
			B.subcommand(locale.voice, locale.roomRenameVoiceDesc, {
				B.string(locale.name, locale.roomRenameVoiceNameDesc, {required = true})
			}),
			B.subcommand(locale.text, locale.roomRenameTextDesc, {
				B.string(locale.name, locale.roomRenameTextNameDesc, {required = true})
			}),
		}),

		B.subcommand(locale.resize, locale.roomResizeDesc, {
			B.integer(
				locale.lobbyCapacity,
				locale.roomResizeCapacityDesc,
				{required = true, min_value = 0, max_value = 99}
			)
		}),

		B.subcommand(locale.bitrate, locale.roomBitrateDesc, {
			B.integer(
				locale.bitrate,
				locale.roomBitrateBitrateDesc,
				{required = true, min_value = 8, max_value = 384}
			)
		}),

		B.subcommand(locale.kick, locale.roomKickDesc, {
			B.user(locale.roomHostUser, locale.roomKickUserDesc, {required = true})
		}),

		voiceTextBothGroup(
			locale.mute,
			locale.roomMuteDesc,
			locale.roomMuteVoiceDesc,
			locale.roomMuteTextDesc,
			locale.roomMuteBothDesc,
			locale.roomMuteBothUserDesc
		),
		voiceTextBothGroup(
			locale.roomUnmute,
			locale.roomUnmuteDesc,
			locale.roomUnmuteVoiceDesc,
			locale.roomUnmuteTextDesc,
			locale.roomUnmuteBothDesc,
			locale.roomUnmuteTextUserDesc
		),
		voiceTextBothGroup(
			locale.hide,
			locale.roomHideDesc,
			locale.roomHideVoiceDesc,
			locale.roomHideTextDesc,
			locale.roomHideBothDesc,
			locale.roomHideTextUserDesc,
			locale.roomHideBothUserDesc
		),
		voiceTextBothGroup(
			locale.roomShow,
			locale.roomShowDesc,
			locale.roomShowVoiceDesc,
			locale.roomShowTextDesc,
			locale.roomShowBothDesc,
			locale.roomShowTextUserDesc,
			locale.roomShowBothUserDesc
		),

		B.subcommand(locale.roomBlock, locale.roomBlockDesc, {
			B.user(locale.roomHostUser, locale.roomBlockUserDesc, {required = true})
		}),

		B.subcommand(locale.roomAllow, locale.roomAllowDesc, {
			B.user(locale.roomHostUser, locale.roomAllowUserDesc, {required = true})
		}),

		B.subcommand(locale.lock, locale.roomLockDesc),
		B.subcommand(locale.roomUnlock, locale.roomUnlockDesc),

		B.subcommand(locale.password, locale.roomPasswordDesc, {
			B.string(locale.password, locale.roomPasswordPasswordDesc)
		}),
	}
}