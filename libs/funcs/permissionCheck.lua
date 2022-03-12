local locale = require "locale"
local config = require "config"

local permission = require "discordia".enums.permission

return function (interaction, channel)
	if not interaction.guild.me:hasPermission(channel, permission.manageChannels) then
		return false, "Bad bot permissions", locale.badBotPermissions
	end

	if config.owners[interaction.user.id] then return true end

	if not (channel and channel.permissions and channel.permissions:has(permission.manageChannels) or interaction.member:hasPermission(channel, permission.manageChannels))then
		return false, "Bad user permissions", locale.badUserPermissions
	end

	return true
end