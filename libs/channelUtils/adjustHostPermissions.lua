local client = require "client"
local channels = require "storage/channels"
local adjustPermissions = require "channelUtils/adjustPermissions"

local warningResponse = require "response/warning"

return function (channel, newHost, oldHost)
	if not channel then return end

	local channelData = channels[channel.id]
	if not channelData then return end

	local lobbyData = channelData.parent
	if not lobbyData and not lobbyData.permissions then return end

	local permissions = lobbyData.permissions:toDiscordia()
	if #permissions == 0 then return end

	local channelOK, channelMissingPermissions = adjustPermissions.allow(newHost, channel, table.unpack(permissions))
	if oldHost then adjustPermissions.clear(oldHost, channel, table.unpack(permissions)) end

	local companionOK, companionMissingPermissions = true
	local companion = client:getChannel(channelData.companion)
	if companion then
		companionOK, companionMissingPermissions = adjustPermissions.allow(newHost, companion, table.unpack(permissions))
		if oldHost then adjustPermissions.clear(oldHost, companion, table.unpack(permissions)) end
	end

	if not (channelOK and companionOK) then
		newHost:send(warningResponse(false, newHost.user.locale, "hostMigrationFail",
		table.concat(channelMissingPermissions or {"none"}, " "), table.concat(companionMissingPermissions or {"none"}, " ")))
	end
end
