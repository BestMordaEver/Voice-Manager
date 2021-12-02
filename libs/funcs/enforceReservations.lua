local logger = require "logger"
local guilds = require "storage/guilds"
local permission = require "discordia".enums.permission

return function (channel)
	if channel.userLimit == 0 then return end

	local reservations = #channel.permissionOverwrites:toArray(function (permissionOverwrite)
		return permissionOverwrite:getObject() ~= channel.guild.me and
			permissionOverwrite.type == "member" and
			permissionOverwrite:getObject().voiceChannel ~= channel and
			permissionOverwrite:getAllowedPermissions():has(permission.connect)
	end)
	if reservations == 0 then return end

	local roleOverwrite = channel:getPermissionOverwriteFor(channel.guild:getRole(guilds[channel.guild.id].role) or channel.guild.defaultRole)

	if reservations >= channel.userLimit - #channel.connectedMembers then
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