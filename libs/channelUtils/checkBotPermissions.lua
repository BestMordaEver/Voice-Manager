local checkPermissions = require "channelUtils/checkPermissions"
local permission = require "discordia".enums.permission --[[@as table<string, permission>]]

return function (channel)
	local bot = channel.me or channel.guild.me
	if channel.me then channel = nil end
	local channelPermissions = bot:getPermissions(channel)

	if channelPermissions:has(permission.administrator) then
		return true
	end

	local mandatoryOk, mandatoryPermissions = checkPermissions(bot, channel,
		permission.manageChannels,
		permission.readMessages,
		permission.connect,
		permission.moveMembers)

	if not mandatoryOk then
		return false, mandatoryPermissions
	end

	local optionalOk, optionalPermissions = checkPermissions(bot, channel,
		permission.manageRoles,
		permission.createInstantInvite,
		permission.sendMessages,
		permission.embedLinks,
		permission.attachFiles,
		permission.speak)

	if not optionalOk then
		return true, optionalPermissions
	end

	return true
end

--[[return function (channel)
	local bot = channel.guild.me
	local channelPermissions = bot:getPermissions(channel)

	if channelPermissions:has(permission.administrator) then
		return true, okEmbed(channel.guild, "botPermissionsAdmin")
	end

	local mandatoryOk, mandatoryPermissions = checkPermissions(bot, channel,
		permission.manageChannels,
		permission.readMessages,
		permission.connect,
		permission.moveMembers)

	if not mandatoryOk then
		return false, warningEmbed(channel.guild, "botPermissionsMandatory", table.concat(mandatoryPermissions, " "), mandatoryPermissions)
	end

	local optionalOk, optionalPermissions = checkPermissions(bot, channel,
		permission.manageRoles,
		permission.createInstantInvite,
		permission.sendMessages,
		permission.embedLinks,
		permission.attachFiles,
		permission.speak)

	if not optionalOk then
		return true, warningEmbed(channel.guild, "botPermissionsOptional", table.concat(optionalPermissions, " "), optionalPermissions)
	end

	return true, okEmbed(channel.guild, "botPermissionsOk")
end]]