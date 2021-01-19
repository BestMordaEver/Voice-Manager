local client = require "client"
local logger = require "logger"
local locale = require "locale"
local embeds = require "embeds/embeds"
local guilds = require "storage/guilds"
local commands = require "commands/init"
local config = require "config"

return function (message)
	-- ignore non-initialized guilds and dms
	if not message.guild then
		return
	elseif not guilds[message.guild.id] or not message.content then
		return
	end
	
	local prefix = message.guild and guilds[message.guild.id].prefix or nil
	
	-- good luck with this one :3
	if message.author.bot or ( -- ignore bots
		not message.mentionedUsers:find(function(user) return user == client.user end) and -- find mentions
		not (prefix and message.content:find(prefix, 1, true))) then 	-- find prefix
		return
	end
	
	logger:log(4, "GUILD %s USER %s => %s", message.guild.id, message.author.id, message.content)
	
	-- cache the member object just in case
	if message.guild then
		message.guild:getMember(message.author)
		message.guild:getMember(client.user)
	end
	
	-- find the request
	local content = 
	prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*(.-)$") or
		message.content:match("^<@.?"..config.id..">%s*(.-)$") or
		message.content
		
	-- what command is it?
	local command = content == "" and "help" or content:match("^(%w+)")
	
	if commands[command] then
		logger:log(4, "GUILD %s USER %s: %s command invoked", message.guild.id, message.author.id, command)
	else
		logger:log(4, "GUILD %s USER %s: Nothing", message.guild.id, message.author.id)
		return
	end
	
	-- call the command, log it, and all in protected call
	local res, logMsg, msgType, msg  = xpcall(commands[command], debug.traceback, message)
	
	-- notify user if failed
	if res then
		logger:log(4, "GUILD %s USER %s: %s", message.guild.id, message.author.id, logMsg)
		message:reply(embeds(msgType, msg))
	else
		message:reply(embeds("error"))
		error(logMsg)
	end
	
	logger:log(4, "GUILD %s USER %s: %s command completed", message.guild.id, message.author.id, command)
end