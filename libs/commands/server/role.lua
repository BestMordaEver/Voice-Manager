local locale = require "locale"
local guilds = require "storage/guilds"

return function (message, role)
	role = message.guild:getRole(role) or message.guild:getRole(role:match("%d+"))
	if not role then
		message:reply(locale.roleBadInput)
		return "Invalid role provided"
	end
	
	guilds[message.guild.id]:setRole(role.id)
	message:reply(locale.roleConfirm)
	return "Server managed role set"
end