local permission = require "discordia".enums.permission

---@param member Member
---@param channel GuildChannel
---@param ... permission
return function (member, channel, ...)
	local permissions = member:getPermissions(channel)
	if channel and channel.permissions then permissions = channel.permissions end
	if permissions:has(permission.administrator) then return true end

	local missingPermissions = {}

	for _, perm in pairs({...}) do
		if not permissions:has(perm) then
			table.insert(missingPermissions, permission(perm))
		end
	end

	if missingPermissions[1] then
		return false, missingPermissions
	else
		return true
	end
end