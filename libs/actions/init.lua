-- all possible bot commands are processed in corresponding files, should return message for logger
return {
	help = require "actions/help",
	
	register = require "actions/register",
	
	unregister = require "actions/unregister",
	
	target = require "actions/target",
	
	template = require "actions/template",
	
	permissions = require "actions/permissions",
	
	limitation = require "actions/limitation",
	
	prefix = require "actions/prefix",
	
	name = require "actions/name",
	
	capacity = require "actions/capacity",
	
	bitrate = require "actions/bitrate",
	
	promote = require "actions/promote",
	
	list = require "actions/list",
	
	stats = require "actions/stats",
	
	support = function (message)
		message:reply("https://discord.gg/tqj6jvT")
		return "Sent support invite"
	end,
	
	shutdown = require "actions/shutdown"
}