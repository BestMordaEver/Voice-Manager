local channels = require "storage".channels

local requiredPerms = {
	bitrate = "manage",
	blocklist = "moderate",
	kick = "moderate",
	mute = "moderate",
	rename = "manage",
	reservations = "moderate",
	resize = "manage",
	unmute = "moderate",
	clear = "manage",
	lock = "moderate",
	password = "moderate",
}

return function (member, channel, permissionName)
	local permissions = channels[channel.id].parent.permissions

	return permissions and channels[channel.id].host == member.user.id and (permissions:has(permissionName) or permissions:has(requiredPerms[permissionName]))
end