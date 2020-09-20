local discordia = require "discordia"
local locale = require "locale"
local guilds = require "storage/guilds"

local client = discordia.storage.client
local permission = discordia.enums.permission

return function (message)
	local prefix = message.guild and guilds[message.guild.id].prefix or nil
	
	local guild = client:getGuild(prefix and message.content:match("^"..prefix:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1").."%s*prefix%s*(%d+).-$") or
		message.content:match("^<@.?601347755046076427>%s*prefix%s*(%d+).-$") or
		message.content:match("^<@.?676787135650463764>%s*prefix%s*(%d+).-$") or
		message.content:match("^%s*prefix%s*(%d+).-$"))
	
	if guild and not guild:getMember(message.author) then
		message:reply(locale.notMember)
		return "Not a member"
	end
	
	local newPrefix = 
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
	
	guild = guild or message.guild
	if not guild then
		message:reply(locale.badServer)
		return "Didn't find the guild"
	end
	if newPrefix and newPrefix ~= "" then
		if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
			message:reply(locale.mentionInVain:format(message.author.mentionString))
			return "Bad user permissions"
		end
		guilds:updatePrefix(guild.id, newPrefix)
		message:reply(locale.prefixConfirm:format(newPrefix))
		return "Set new prefix"
	else
		message:reply(locale.prefixThis:format(guilds[guild.id].prefix))
		return "Sent current prefix"
	end
end