local prefinalizer = require "prefinalizer"
local client = require "discordia".storage.client

return function (message)
	local guild, limitation = message.content:match("limitation%s*(%d*)%s*(%d*)$")
	
	if limitation == "" then
		limitation, guild = guild, message.guild
	else
		guild = client:getGuild(guild)
	end
	
	prefinalizer.limitation(message, guild, limitation)
end