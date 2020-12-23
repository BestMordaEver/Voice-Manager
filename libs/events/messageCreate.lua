local client = require "client"
local logger = require "logger"
local locale = require "locale"
local guilds = require "storage/guilds"
local commands = require "commands/init"
local logAction = require "funcs/logAction"
local config = require "config"


return function (message)
	-- ignore non-initialized guilds
	if message.guild and not guilds[message.guild.id] or not message.content then return end
	
	local prefix = message.guild and guilds[message.guild.id].prefix or nil
	
	-- good luck with this one :3
	if message.author.bot or ( -- ignore bots
		not message.mentionedUsers:find(function(user) return user == client.user end) and -- find mentions
		not (prefix and message.content:find(prefix, 1, true)) and 	-- find prefix
		message.guild) then	-- of just roll with it if dm
		return
	end
	
	logAction(message, "=> "..message.content)
	
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
	if command == "matchmaking" then command = content:match("^matchmaking (%w+)") end
	
	if commands[command] then
		logAction(message, command.." command invoked")
	else
		logAction(message, "Nothing")
		return
	end
	
	--[[
	-- call the command, log it, and all in protected call
	local res, msg = xpcall(commands[command], debug.traceback, message)
	
	-- notify user if failed
	if res then
		logAction(message, msg)
	else
		message:reply(locale.error)
		error(msg)
	end
	--]]
	
	-- [[
	logAction(message, commands[command](message))
	--]]
	
	logAction(message, command .. " command completed")
end