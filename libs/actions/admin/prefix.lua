local discordia = require "discordia"
local guilds = require "storage/guilds"
local prefinalizer = require "prefinalizer"

local client = discordia.storage.client

return function (message)
	local prefix = message.guild and guilds[message.guild.id].prefix or nil
	
	local guild = client:getGuild(prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(%d+).-$") or
		message.content:match("^<@.?601347755046076427>%s*prefix%s*(%d+).-$") or
		message.content:match("^<@.?676787135650463764>%s*prefix%s*(%d+).-$") or
		message.content:match("^%s*prefix%s*(%d+).-$"))
	guild = guild or message.guild
	
	prefix = 
		guild and (
			prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*%d+%s*(.-)$") or
			message.content:match("^<@.?601347755046076427>%s*prefix%s*%d+%s*(.-)$") or
			message.content:match("^<@.?676787135650463764>%s*prefix%s*%d+%s*(.-)$") or
			message.content:match("^%s*prefix%s*%d+%s*(.-)$")
		) or (
			prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(.-)$") or
			message.content:match("^<@.?601347755046076427>%s*prefix%s*(.-)$") or
			message.content:match("^<@.?676787135650463764>%s*prefix%s*(.-)$") or
			message.content:match("^%s*prefix%s*(.-)$"))
	
	prefinalizer.prefix(message, guild, prefix)
end