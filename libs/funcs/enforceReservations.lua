local guilds = require "storage/guilds"
local permission = require "discordia".enums.permission

return function (channel)
	if channel.userLimit == 0 then return end
	
	local roleOverwrite = channel:getPermissionOverwriteFor(channel.guild:getRole(guilds[channel.guild.id].role) or channel.guild.defaultRole)
	if #channel.permissionOverwrites:toArray(function (permissionOverwrite)
		return permissionOverwrite.type == "member" and
			permissionOverwrite:getObject().voiceChannel ~= channel and
			permissionOverwrite:getAllowedPermissions():has(permission.connect)
	end) >= channel.userLimit - channel.connectedMembers then
		if not roleOverwrite:getDeniedPermissions():has(permission.connect) then
			roleOverwrite:denyPermissions(permission.connect)
		end
	else
		if roleOverwrite:getDeniedPermissions():has(permission.connect) then
			roleOverwrite:clearPermissions(permission.connect)
		end
	end
end