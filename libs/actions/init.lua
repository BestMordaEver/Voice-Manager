-- all possible bot commands are processed in corresponding files, should return message for logger
return {
	help = require "actions/misc/help",
	
	register = require "actions/admin/register",
	
	unregister = require "actions/admin/unregister",
	
	target = require "actions/admin/target",
	
	template = require "actions/admin/template",
	
	permissions = require "actions/admin/permissions",
	
	limitation = require "actions/admin/limitation",
	
	prefix = require "actions/admin/prefix",
	
	ban = require "actions/host/ban",
	
	deafen = require "actions/host/deafen",
	
	mute = require "actions/host/mute",
	
	reserve = require "actions/host/reserve",
	
	name = require "actions/host/name",
	
	capacity = require "actions/host/capacity",
	
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