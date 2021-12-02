local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, lobby, role)
	role = message.guild:getRole(role) or message.guild:getRole((role or ""):match("%d+")) or message.guild.defaultRole
	if not role then
		return "Invalid role provided", "warning", locale.roleBadInput
	end

	lobbies[lobby.id]:setRole(role.id)
	return "Lobby managed role set", "ok", locale.roleConfirm
end