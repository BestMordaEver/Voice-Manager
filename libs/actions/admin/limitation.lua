local discordia = require "discordia"
local locale = require "locale"
local guilds = require "storage/guilds"

local client = discordia.storage.client
local permission = discordia.enums.permission

return function (message)
	local guild, limitation = message.content:match("limitation%s*(%d*)%s*(%d*)$")
	
	
	if limitation == "" then
		limitation, guild = guild, message.guild
	else
		guild = client:getGuild(guild)
	end
	
	if not guild then
		message:reply(locale.badServer)
		return "Didn't find the guild"
	end
	if guild and not guild:getMember(message.author) then
		message:reply(locale.notMember)
		return "Not a member"
	end
	
	if limitation ~= "" then
		if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
			message:reply(locale.mentionInVain:format(message.author.mentionString))
			return "Bad user permissions"
		end
		limitation = tonumber(limitation)
		if not limitation or limitation > 100000 or limitation < 1 then
			message:reply(locale.limitationOOB)
			return "Limitation OOB"
		end
		
		guilds[guild.id]:updateLimitation(limitation)
		message:reply(locale.limitationConfirm:format(limitation))
		return "Set new limitation"
	else
		message:reply(locale.limitationThis:format(guilds[guild.id].limitation))
		return "Sent current limitation"
	end
end