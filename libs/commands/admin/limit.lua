local client = require "client"
local guilds = require "storage/guilds"

return function (message)
	local guild, limit = message.content:match("limit%s*(%d*)%s*(%d*)$")
	
	if limit == "" then
		limit, guild = guild, message.guild
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

	if limit ~= "" then
		if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
			message:reply(locale.mentionInVain:format(message.author.mentionString))
			return "Bad user permissions"
		end
		
		limit = tonumber(limit)
		if not limit or limit > 500 or limit < 1 then
			message:reply(locale.limitationOOB)
			return "limit OOB"
		end
		
		guilds[guild.id]:updateLimitation(limit)
		message:reply(locale.limitationConfirm:format(limit))
		return "Set new limit"
	else
		message:reply(locale.limitationThis:format(guilds[guild.id].limit))
		return "Sent current limit"
	end
end