local config = require "config"
local locale = require "locale"
local client = require "client"

local embeds = require "embeds/embeds"
local channels = require "storage/channels"
local guilds = require "storage/guilds"
local permission = require "discordia".enums.permission
local Permissions = require "discordia".Permissions

local roomCommands = {
	mute = "mute, unmute",
	moderate = "mute, unmute, block, reserve, kick",
	rename = "rename",
	resize = "resize",
	bitrate = "bitrate",
	manage = "rename, resize, bitrate"
}

-- no embed data is saved, since this is non-interactive embed
embeds:new("roomInfo", function (room)
	local parent = channels[room.id].parent or guilds[room.guild.id]
	local blocklist, reservations, muted, commands = "","","",""
	
	local overwrites = room.permissionOverwrites:toArray(function(overwrite) return overwrite.type == "member" end)
	
	for _,overwrite in pairs(overwrites) do
		if Permissions(overwrite.allowedPermissions):has(permission.connect) then
			reservations = reservations..member.user.mentionString.." ,"
		end
		if Permissions(overwrite.deniedPermissions):has(permission.connect) then
			blocklist = blocklist..member.user.mentionString.." ,"
		end
		if Permissions(overwrite.deniedPermissions):has(permission.speak) then
			muted = muted..member.user.mentionString.." ,"
		end
	end
	for name, _ in pairs(parent.permissions.bits) do
		if parent.permissions:has(name) then commands = commands..roomCommands[name]..", " end
	end
	
	reservations = reservations == "" and locale.none or reservations:sub(1,-3)
	blocklist = blocklist == "" and locale.none or blocklist:sub(1,-3)
	muted = muted == "" and locale.none or muted:sub(1,-3)
	commands = commands == "" and locale.none or commands:sub(1,-3)
	
	local embed = {
		title = locale.roomInfoTitle:format(room.name),
		color = 6561661,
		description = locale.roomInfo:format(reservations, blocklist, muted, commands)
	}
	return embed
end)