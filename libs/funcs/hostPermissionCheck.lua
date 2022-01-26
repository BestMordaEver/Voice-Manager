local guilds = require "storage/guilds"
local channels = require "storage/channels"

local requiredPerms = {
	bitrate = "manage",
	blocklist = "moderate",
	kick = "moderate",
	mute = "moderate",
	rename = "manage",
	reservations = "moderate",
	resize = "manage",
	unmute = "moderate",
}

return function (member, channel, permissionName)
	local permissions = channels[channel.id].parent and channels[channel.id].parent.permissions or guilds[channel.guild.id].permissions

	return channels[channel.id].host == member.user.id and (permissions:has(permissionName) or permissions:has(requiredPerms[permissionName]))
end