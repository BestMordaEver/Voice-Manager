local client = require "client"
local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local channels = require "handlers/storageHandler".channels

local availableCommands = require "embeds/availableCommands"

local permission = require "discordia".enums.permission
local blurple = embedHandler.colors.blurple

return embedHandler("roomInfo", function (room, ephemeral)
	local blocklist, reservations, muted = "","",""

	for _,overwrite in pairs(room.permissionOverwrites:toArray(function(overwrite) return overwrite.type == 1 end)) do
		if overwrite:getObject().user ~= client.user and overwrite:getAllowedPermissions():has(permission.connect) then
			reservations = reservations..overwrite:getObject().user.mentionString.." "
		end
		if overwrite:getDeniedPermissions():has(permission.connect, permission.sendMessages) then
			blocklist = blocklist..overwrite:getObject().user.mentionString.." "
		end
		if overwrite:getDeniedPermissions():has(permission.speak) then
			muted = muted..overwrite:getObject().user.mentionString.." "
		end
	end

	local commands = availableCommands(room)

	if reservations == "" then reservations = locale.none end
	if blocklist == "" then blocklist = locale.none end
	if muted == "" then muted = locale.none end
	local user = client:getUser(channels[room.id].host)

	return {embeds = {{
		title = locale.roomInfoTitle:format(room.name),
		color = blurple,
		description = locale.roomInfo:format(user.mentionString, reservations, blocklist, muted, commands)
	}}, ephemeral = ephemeral}
end)