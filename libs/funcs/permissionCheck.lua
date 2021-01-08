local locale = require "locale"
local permission = require "discordia".enums.permission

return function (message, channel)
	if not message.member:hasPermission(channel, permission.manageChannels) then
		message:reply(locale.badUserPermissions)
		return false, "Bad user permissions"
	end
	
	if not message.guild.me:hasPermission(channel, permission.manageChannels) then
		message:reply(locale.badBotPermissions)
		return false, "Bad user permissions"
	end
	
	return true
end