local logger = require "logger"
local channels = require "storage/channels"

local permission = require "discordia".enums.permission
local overwriteType = require "discordia".enums.overwriteType

return function (channel)
	local channelData = channels[channel.id]
	local guild = channel.guild

	channelData:delete()

	if not channelData.parent then return end

	local perms = channelData.parent.permissions:toDiscordia()
	if #perms == 0 or not guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then return end

	for _, permissionOverwrite in pairs(channel.permissionOverwrites) do
		if permissionOverwrite.type == overwriteType.member then permissionOverwrite:delete() end
	end

	logger:log(4, "GUILD %s CHANNEL %s: reset", guild.id, channel.id)
end