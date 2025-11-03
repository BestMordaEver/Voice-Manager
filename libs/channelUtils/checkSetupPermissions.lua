local permission = require "discordia".enums.permission
local config = require "config"

local warningResponse = require "response/warning"

local checkBotPermissions = require "channelUtils/checkBotPermissions"

return
---@param interaction MessagingInteraction
---@param channel? GuildChannel
---@return boolean
---@return string? logMessage
---@return table? response
function (interaction, channel)
	local ok, missingPermissions = checkBotPermissions(channel or interaction.guild)
	if not ok then
		return false, "Bad bot permissions", warningResponse(true, interaction.locale, "botPermissionsMandatory", table.concat(missingPermissions, " "))
	end

	if config.owners[interaction.user.id] then return true end

	if interaction.member:hasPermission(channel, permission.manageChannels) then
		return true
	else
		return false, "Bad user permissions", warningResponse(true, interaction.locale, "badUserPermissions")
	end
end