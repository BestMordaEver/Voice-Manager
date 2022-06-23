local logger = require "logger"

local channels = require "storage".channels

local permission = require "discordia".enums.permission
local overwriteType = require "discordia".enums.overwriteType

return function (channel)
	local reservations = channel.userLimit == 0 and 0 or #channel.permissionOverwrites:toArray(function (permissionOverwrite)
		return permissionOverwrite:getObject() ~= channel.guild.me and
			permissionOverwrite.type == overwriteType.member and
			permissionOverwrite:getObject().voiceChannel ~= channel and
			permissionOverwrite:getAllowedPermissions():has(permission.connect)
	end)

	local parent = channels[channel.id].parent
	local roleOverwrite = channel:getPermissionOverwriteFor(parent and channel.guild:getRole(parent.role) or channel.guild.defaultRole)

	if reservations ~= 0 and reservations >= channel.userLimit - #channel.connectedMembers then
		if not roleOverwrite:getDeniedPermissions():has(permission.connect) then
			logger:log(4, "GUILD %s ROOM %s: locked", channel.guild.id, channel.id)
			roleOverwrite:denyPermissions(permission.connect)
		end
	else
		if roleOverwrite:getDeniedPermissions():has(permission.connect) then
			logger:log(4, "GUILD %s ROOM %s: unlocked", channel.guild.id, channel.id)
			roleOverwrite:clearPermissions(permission.connect)
		end
	end
end