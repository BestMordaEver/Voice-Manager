local locale = require "locale"
local client = require "client"
local lobbiesInfoEmbed = require "embeds/lobbiesInfo"
local dialogue = require "utils/dialogue"

return function (message)
	local guild = message.content:match("lobbies%s*(.-)$")
	
	if guild == "" then
		guild = message.guild
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
	
	lobbiesInfoEmbed(message, guild)
	
	dialogue(message.author.id, "lobbies", guild.id)
end