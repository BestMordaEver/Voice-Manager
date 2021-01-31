local locale = require "locale"
local config = require "config"
local permission = require "discordia".enums.permission

return function (message, channel)
	if not message.guild.me:hasPermission(channel, permission.manageChannels) then
		return false, "Bad user permissions", locale.badBotPermissions
	end

	if message.author.id == config.ownerID then return true end -- unlimited power
	
	if not message.member:hasPermission(channel, permission.manageChannels) then
		return false, "Bad user permissions", locale.badUserPermissions
	end
	
	return true
end