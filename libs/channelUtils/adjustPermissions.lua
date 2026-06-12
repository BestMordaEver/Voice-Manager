local checkBotPermissions = require "channelUtils/checkBotPermissions"
local permission = require "discordia".enums.permission

local function adjust (overwrite, method, channel, ...)
	local permissions = {...}
	if not channel.guild.me:getPermissions():has(permission.administrator) then
		local filteredPermissions = {}
		for _, perm in pairs(permissions) do
			if perm ~= permission.manageRoles then
				table.insert(filteredPermissions, perm)
			end
		end

		permissions = filteredPermissions
	end

	local ok, missingBotPermissions = checkBotPermissions(channel)

	if ok then
		if permissions[1] then
			method(overwrite, table.unpack(permissions))
		end
	else
		local missingPermissionSet = {}
		for _, perm in pairs(missingBotPermissions or {}) do
			missingPermissionSet[permission[perm] or perm] = true
		end

		for _, perm in pairs(permissions) do
			if not missingPermissionSet[perm] then
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