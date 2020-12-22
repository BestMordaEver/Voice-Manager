local locale = require "locale"
local client = require "client"

return function (message)
	local guild = message.content:match("companions%s*(.-)$")
	
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