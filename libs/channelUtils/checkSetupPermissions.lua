local permission = require "discordia".enums.permission
local config = require "config"

local warningEmbed = require "response/warning"

local checkBotPermissions = require "channelUtils/checkBotPermissions"
local checkPermissions = require "channelUtils/checkPermissions"

-- channel is optional
return function (interaction, channel)
	local ok, missingPermissions = checkBotPermissions(channel)
	if not ok then
		return false, "Bad bot permissions", warningEmbed(interaction, "botPermissionsMandatory", table.concat(missingPermissions, " "), missingPermissions)
	end

	if config.owners[interaction.user.id] then return true end

	if interaction.member:hasPermission(channel, permission.manageChannels) then
		return true
	else
		return false, "Bad user permissions", warningEmbed(interaction, "badUserPermissions")
	end
end