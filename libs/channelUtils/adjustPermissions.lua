local checkBotPermissions = require "channelUtils/checkBotPermissions"
local permission = require "discordia".enums.permission

local function adjust (overwrite, method, channel, ...)
	local permissions = {...}
	for index, perm in pairs(permissions) do
		if perm == permission.manageRoles then
			if not channel.guild.me:getPermissions():has(permission.administrator) then
				permissions[index] = nil
			end
			break
		end
	end

	local ok, _, missingBotPermissions = checkBotPermissions(channel)

	if ok then
		method(overwrite, ...)
	else
		for _, perm in pairs(...) do
			if not missingBotPermissions[perm] then
				method(overwrite, perm)
			end
		end
	end

	return ok, missingBotPermissions
end

return {
	allow = function (member, channel, ...)
		local o = channel:getPermissionOverwriteFor(member)
		return adjust(o, o.allowPermissions, channel, ...)
	end,

	clear = function (member, channel, ...)
		local o = channel:getPermissionOverwriteFor(member)
		return adjust(o, o.clearPermissions, channel, ...)
	end,

	deny = function (member, channel, ...)
		local o = channel:getPermissionOverwriteFor(member)
		return adjust(o, o.denyPermissions, channel, ...)
	end
}