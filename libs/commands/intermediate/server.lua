local locale = require "locale"
local client = require "client"
local serverInfoEmbed = require "embeds/serverInfo"
local dialogue = require "utils/dialogue"

return function (message)
	local guild = message.content:match("server%s*(.-)$")
	
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
	
	serverInfoEmbed(message, guild)
	
	dialogue(message.author.id, "server", guild.id)
end