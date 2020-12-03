local locale = require "locale"
local client = require "discordia".storage.client

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
end