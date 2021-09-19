local client = require "client"
local logger = require "logger"
local locale = require "locale"
local embeds = require "embeds/embeds"
local guilds = require "storage/guilds"
local commands = require "commands/init"

return function (message)
	-- ignore non-initialized guilds and dms
	if not message.guild then
		return
	elseif not guilds[message.guild.id] or not message.content then
		return
	end
	
	local prefix = guilds[message.guild.id].prefix
	
	-- good luck with this one :3
	if message.author.bot or not ( -- ignore bots
		message.mentionedUsers:find(function(user) return user == client.user end) or -- find mentions
		message.content:find(prefix, 1, true)) then 	-- find prefix
		return
	end
	
	-- cache the member object just in case
	if message.guild then
		message.guild:getMember(message.author)
		message.guild:getMember(client.user)
	end
	
	-- find the request
	local content = 
		message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*(.-)$") or
		message.content:match("^<@.?"..client.user.id..">%s*(.-)$")
		
	-- what command is it?
	if not content then return end
	local command = content == "" and "help" or content:match("^(%w+)")
	
	logger:log(4, "GUILD %s USER %s => %s", message.guild.id, message.author.id, message.content)
	
	if commands[command] then
		logger:log(4, "GUILD %s USER %s: %s command invoked", message.guild.id, message.author.id, command)
	else
		logger:log(4, "GUILD %s USER %s: nothing", message.guild.id, message.author.id)
		return
	end
	
	-- call the command, log it, and all in protected call
	local res, logMsg, embedType, data = xpcall(commands[command], debug.traceback, message)
	
	-- notify user if failed
	if res then
		logger:log(4, "GUILD %s USER %s: %s", message.guild.id, message.author.id, logMsg)
		local embed = embeds(embedType, data, message)
		client:emit("embedSent", embedType, message, message:reply(embed), embed)
	else
		message:reply(embeds("error"))
		error(logMsg)
	end
	
	logger:log(4, "GUILD %s USER %s: %s command completed", message.guild.id, message.author.id, command)
end