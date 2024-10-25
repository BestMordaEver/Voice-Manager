local client = require "client"
local logger = require "logger"

local channels = require "storage/channels"
local permission = require "discordia".enums.permission

return function (channel, member)
	local channelData = channels[channel.id]
	local guild = channel.guild

	if channelData.parent then
		local parent = client:getChannel(channelData.parent.id)
		if parent then
			local overwrite = parent:getPermissionOverwriteFor(member)
			if not (overwrite:getAllowedPermissions():has(permission.connect) or overwrite:getDeniedPermissions():has(permission.sendMessages)) then
				overwrite:clearPermissions(permission.connect)
			end
		end
		channel:delete()
		logger:log(4, "GUILD %s ROOM %s: finished password flow", guild.id, channel.id)
	end
end