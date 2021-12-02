local locale = require "locale"
local guilds = require "storage/guilds"

return function (message, role)
	role = message.guild:getRole(role) or message.guild:getRole((role or ""):match("%d+")) or message.guild.defaultRole
	if not role then
		return "Invalid role provided", "warning", locale.roleBadInput
	end

	guilds[message.guild.id]:setRole(role.id)
	return "Server managed role set", "ok", locale.roleConfirm
end