-- all possible bot commands are processed in corresponding files, should return message for logger
return {
	reset = require "actions/admin/reset",
	help = require "actions/misc/help",
	register = require "actions/admin/register",
	unregister = require "actions/admin/unregister",
	target = require "actions/admin/target",
	["matchmaking target"] = require "actions/admin/target",
	["matchmaking template"] = require "actions/admin/template",
	template = require "actions/admin/template",
	permissions = require "actions/admin/permissions",
	capacity = require "actions/admin/capacity",
	companion = require "actions/admin/companion",
	limitation = require "actions/admin/limitation",
	prefix = require "actions/admin/prefix",
	blacklist = require "actions/host/moderate",
	whitelist = require "actions/host/moderate",
	mute = require "actions/host/mute",
	unmute = require "actions/host/mute",
	name = require "actions/host/name",
	resize = require "actions/host/resize",
	bitrate = require "actions/host/bitrate",
	promote = require "actions/host/promote",
	list = require "actions/misc/list",
	stats = require "actions/misc/stats",
	support = function (message)
		message:reply("https://discord.gg/tqj6jvT")
		return "Sent support invite"
	end,
	shutdown = require "actions/misc/shutdown"
}