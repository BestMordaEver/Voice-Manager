-- all possible bot commands are processed in corresponding files, should return message for logger
return {
	reset = require "commands/admin/reset",
	help = require "commands/misc/help",
	register = require "commands/admin/register",
	unregister = require "commands/admin/unregister",
	target = require "commands/admin/target",
	["matchmaking target"] = require "commands/admin/target",
	["matchmaking template"] = require "commands/admin/template",
	template = require "commands/admin/template",
	permissions = require "commands/admin/permissions",
	capacity = require "commands/admin/capacity",
	companion = require "commands/admin/companion",
	limitation = require "commands/admin/limitation",
	prefix = require "commands/admin/prefix",
	
	server = require "commands/intermediate/server",
	
	blacklist = require "commands/host/moderate",
	whitelist = require "commands/host/moderate",
	mute = require "commands/host/mute",
	unmute = require "commands/host/mute",
	name = require "commands/host/name",
	resize = require "commands/host/resize",
	bitrate = require "commands/host/bitrate",
	promote = require "commands/host/promote",
	list = require "commands/misc/list",
	stats = require "commands/misc/stats",
	support = function (message)
		message:reply("https://discord.gg/tqj6jvT")
		return "Sent support invite"
	end,
	shutdown = require "commands/misc/shutdown"
}