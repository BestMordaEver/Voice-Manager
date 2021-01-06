local locale = require "locale"
local guilds = require "storage/guilds"
local botPermissions = require "utils/botPermissions"

return function (message, permissions)
	local permissionBits = botPermissions()
	
	for permission in permissions:gmatch("%a+") do
		if permissionBits.bits[permission] then
			permissionBits.bitfield = permissionBits.bitfield + permissionBits.bits[permission]
		elseif not (permission == "allow" or permission == "deny") then
			message:reply(locale.permissionsBadInput:format(permission))
			return "Unknown permission provided"
		end
	end
	
	local guildData = guilds[message.guild.id]
	if message.content:match("allow") then
		permissionBits = guildData.permissions + permissionBits
	elseif message.content:match("deny") then
		permissionBits = guildData.permissions - permissionBits
	end
	
	guildData:setPermissions(permissionBits)
	message:reply(locale.permissionsConfirm)
	return "Set new permissions "..tostring(permissionBits)
end