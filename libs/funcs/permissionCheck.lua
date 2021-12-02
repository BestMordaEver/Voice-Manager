local locale = require "locale"
local config = require "config"
local permission = require "discordia".enums.permission

return function (message, channel)
	if not message.guild.me:hasPermission(channel, permission.manageChannels) then
		return false, "Bad bot permissions", locale.badBotPermissions
	end

	if config.owners[message.author.id] then return true end

	if message.member.guild ~= channel.guild or not message.member:hasPermission(channel, permission.manageChannels) then
		return false, "Bad user permissions", locale.badUserPermissions
	end

	return true
end