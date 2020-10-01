local discordia = require "discordia"
local locale = require "locale"
local guilds = require "storage/guilds"
local actions = require "actions/init"

local client = discordia.storage.client
local logger = discordia.storage.logger

-- message is a discord object, if it doesn't have guild property - it's a DM
local function logAction (message, logMsg)
	if message.guild then
		logger:log(4, "GUILD %s USER %s: %s", message.guild.id, message.author.id, logMsg)
	else
		logger:log(4, "DM %s: %s", message.author.id, logMsg)
	end
end

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
	if message.guild then message.guild:getMember(message.author) end
	
	-- find the request
	local content = 
	prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*(.-)$") or
		message.content:match("^<@.?601347755046076427>%s*(.-)$") or
		message.content:match("^<@.?676787135650463764>%s*(.-)$") or	-- stop discriminating LabRat
		message.content
		
	-- what command is it?
	local command = content == "" and "help" or content:match("^(%w+)")
	
	if actions[command] then 
		logAction(message, command.." action invoked")
	else
		logAction(message, "Nothing")
		return
	end
	
	-- call the command, log it, and all in protected call
	local res, msg = xpcall(actions[command], debug.traceback, message)
	
	-- notify user if failed
	if res then
		logAction(message, res)
	else
		--message:reply(locale.error)
		error(msg)
	end
	
	logAction(message, command .. " action completed")
end