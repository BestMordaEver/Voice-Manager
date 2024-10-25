local permission = require "discordia".enums.permission

return function (channel, ...)
	channel.guild.me:getPermissions(channel):has(permission.manageRoles, ...)

end