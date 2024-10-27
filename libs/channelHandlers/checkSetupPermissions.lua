local permission = require "discordia".enums.permission
local config = require "config"

return function (interaction, channel)
	if not interaction.guild.me:hasPermission(channel, permission.manageChannels) then
		return false, "Bad bot permissions", "badBotPermissions"
	end

	if config.owners[interaction.user.id] then return true end

	if channel.permissions and channel.permissions:has(permission.manageChannels)
			or
		(interaction.member or channel.guild:getMember(interaction.user)):hasPermission(channel, permission.manageChannels) then
		return true
	end

	return false, "Bad user permissions", "badUserPermissions"
end