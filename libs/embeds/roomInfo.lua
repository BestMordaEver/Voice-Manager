local locale = require "locale"

local embeds = require "embeds/embeds"
local channels = require "storage/channels"
local availableCommands = require "funcs/availableCommands"
local permission = require "discordia".enums.permission
local Permissions = require "discordia".Permissions
local colors = embeds.colors

-- no embed data is saved, since this is non-interactive embed
embeds:new("roomInfo", function (room)
	local blocklist, reservations, muted = "","",""
	
	for _,overwrite in pairs(room.permissionOverwrites:toArray(function(overwrite) return overwrite.type == "member" end)) do
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
	
	local commands = availableCommands(room)
	
	if reservations == "" then reservations = locale.none end
	if blocklist == "" then blocklist = locale.none end
	if muted == "" then muted = locale.none end
	
	return {
		title = locale.roomInfoTitle:format(room.name),
		color = colors.blurple,
		description = locale.roomInfo:format(reservations, blocklist, muted, commands)
	}
end)