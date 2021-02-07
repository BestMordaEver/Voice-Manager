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
			reservations = reservations..overwrite:getObject().user.mentionString.." "
		end
		if Permissions(overwrite.deniedPermissions):has(permission.connect) then
			blocklist = blocklist..overwrite:getObject().user.mentionString.." "
		end
		if Permissions(overwrite.deniedPermissions):has(permission.speak) then
			muted = muted..overwrite:getObject().user.mentionString.." "
		end
	end
	for name, _ in pairs(parent.permissions.bits) do
		if parent.permissions:has(name) and not commands:match(roomCommands[name]) then commands = commands..roomCommands[name]..", " end
	end
	
	if reservations == "" then reservations = locale.none end
	if blocklist == "" then blocklist = locale.none end
	if muted == "" then muted = locale.none end
	commands = commands == "" and locale.none or commands:sub(1,-3)
	
	local embed = {
		title = locale.roomInfoTitle:format(room.name),
		color = 6561661,
		description = locale.roomInfo:format(reservations, blocklist, muted, commands)
	}
	return embed
end)