local requiredPerms = {
	bitrate = {manage = true},
	rename = {manage = true},
	resize = {manage = true},
	kick = {moderate = true},
	mute = {moderate = true},
	unmute = {moderate = true, mute = true},
	hide = {moderate = true},
	show = {moderate = true, hide = true},
	lock = {moderate = true},
	unlock = {moderate = true, lock = true},
	block = {moderate = true, lock = true},
	unblock = {moderate = true, lock = true},
	clear = {manage = true},
	password = {moderate = true}
}

return function (member, channel, permissionName)
	local permissions = channels[channel.id].parent.permissions
	if not permissions then return false end
	if channels[channel.id].host ~= member.user.id then return false end

	if permissions:has(permissionName) then return true end

	for _, subpermissions in pairs(requiredPerms) do
		for permission, _ in pairs(subpermissions) do
			if permissions:has(permission) then return true end
		end
	end

	return false
end