---@alias textLine sharedLine | helpLine | runtimeLine | slashLine
---@enum (key) sharedLine
local locale = {
	-- shared names (used in both slash definitions and runtime)
	add = "add",
	remove = "remove",
	enable = "enable",
	disable = "disable",
	view = "view",
	text = "text",
	voice = "voice",
	role = "role",
	channel = "channel",
	category = "category",
	target = "target",
	bitrate = "bitrate",
	lobby = "lobby",
	room = "room",
	matchmaking = "matchmaking",
	server = "server",
	limit = "limit",
	name = "name",
	lobbyConfigured = "A lobby to be configured",

	-- permission names
	moderate = "moderate",
	manage = "manage",
	rename = "rename",
	resize = "resize",
	kick = "kick",
	mute = "mute",
	hide = "hide",
	lock = "lock",
	password = "password",

	error = "*%s*\nThis error has been reported to the developers. Contact us if you need additional help - https://discord.gg/tqj6jvT",
	errorReaction = {
		"I'm sowwy",
		"There go my evening plans",
		"I saw this one coming",
		"Kinda saw this one coming",
		"Never saw this one coming",
		"Is everyone alive?",
		"I sure hope nobody got injured",
		"ow",
		"Ow, my leg",
		"Ow, my head",
		"'Tis but a flesh wound!",
		"That's why we can't have nice things",
		"Slap a bandaid on, that'll do for now",
		"bonk",
		"This is so sad",
		"Now you're just doing this on purpose, aren't you?",
		"I swear I'm not doing this on purpose!",
		"Error that tastes like cookies? Fascinating...",
		"Does anyone smell almonds?",
		"Valhalla, take me!",
		"Pretty sure this isn't supposed to happen",
		"Yeah, just let me grab my comically large wrench",
		"smacks computer with a comically large wrench",
		"Local bot repeatedly embarasses his owner",
		"Add this one to the list",
		"This just keeps happening!",
		"Further testing required...",
	}
}

for k, v in pairs(require "locale/en-US/help") do locale[k] = v end
for k, v in pairs(require "locale/en-US/runtime") do locale[k] = v end
for k, v in pairs(require "locale/en-US/slash") do locale[k] = v end

locale.errorReaction[#locale.errorReaction + 1] = string.format("There is exactly one in %d chance to get this error message!", #locale.errorReaction + 1)

return locale
