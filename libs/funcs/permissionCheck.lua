local locale = require "locale"
local permission = require "discordia".enums.permission

return function (message, channel)
	if not message.member:hasPermission(channel, permission.manageChannels) then
		return false, "Bad user permissions", locale.badUserPermissions
	end
	
	if not message.guild.me:hasPermission(channel, permission.manageChannels) then
		return false, "Bad user permissions", locale.badBotPermissions
	end
	
	return true
end