local config = require "config"
local guilds = require "storage/guilds"
local channels = require "storage/channels"
local permission = require "discordia".enums.permission

local perms = {
	mute = "moderate",
	moderate = "moderate",
	rename = "manage",
	resize = "manage",
	bitrate = "manage",
	manage = "manage"
}

return function (member, channel, permissionName)
	if config.owners[member.user.id] then return true end
	
	local permissions = channels[channel.id].parent and channels[channel.id].parent.permissions or guilds[channel.guild.id].permissions
	
	return member:hasPermission(channel, permission.administrator) or (
		channels[channel.id].host == member.user.id and (
			permissions:has(permissionName) or permissions:has(perms[permissionName])))
end