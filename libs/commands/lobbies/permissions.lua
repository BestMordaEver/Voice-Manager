local locale = require "locale"
local lobbies = require "storage/lobbies"
local botPermissions = require "utils/botPermissions"

return function (message, channel, permissions)
	local permissionBits = botPermissions()
	
	for permission in permissions:gmatch("%a+") do
		if permissionBits.bits[permission] then
			permissionBits.bitfield = permissionBits.bitfield + permissionBits.bits[permission]
		elseif not (permission == "allow" or permission == "deny") then
			message:reply(locale.permissionsBadInput:format(permission))
			return "Unknown permission provided"
		end
	end
	
	local lobbyData = lobbies[channel.id]
	if message.content:match("allow") then
		permissionBits = lobbyData.permissions + permissionBits
	elseif message.content:match("deny") then
		permissionBits = lobbyData.permissions - permissionBits
	end
	
	lobbyData:setPermissions(permissionBits)
	message:reply(locale.permissionsConfirm)
	return "Lobby permissions set"
end