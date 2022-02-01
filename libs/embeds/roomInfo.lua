local locale = require "locale"
local embeds = require "embeds"

local availableCommands = require "embeds/availableCommands"

local permission = require "discordia".enums.permission
local Permissions = require "discordia".Permissions
local blurple = embeds.colors.blurple

return embeds("roomInfo", function (room)
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

	return {embeds = {{
		title = locale.roomInfoTitle:format(room.name),
		color = blurple,
		description = locale.roomInfo:format(reservations, blocklist, muted, commands)
	}}}
end)