local client = require "client"
local locale = require "locale"
local embeds = require "embeds"

local channels = require "storage".channels

local availableCommands = require "embeds/availableCommands"

local permission = require "discordia".enums.permission
local blurple = embeds.colors.blurple

return embeds("chatInfo", function (room, ephemeral)
	local hidden, shown, muted = "","",""

	local companion = client:getChannel(channels[room.id].companion)

	for _,overwrite in pairs(companion.permissionOverwrites:toArray(function(overwrite) return overwrite.type == "member" end)) do
		if overwrite:getObject().user ~= client.user and overwrite:getAllowedPermissions():has(permission.readMessages) then
			hidden = hidden..overwrite:getObject().user.mentionString.." "
		end
		if overwrite:getDeniedPermissions():has(permission.readMessages) then
			shown = shown..overwrite:getObject().user.mentionString.." "
		end
		if overwrite:getDeniedPermissions():has(permission.sendMessages) then
			muted = muted..overwrite:getObject().user.mentionString.." "
		end
	end

	local _, commands = availableCommands(room)

	if hidden == "" then hidden = locale.none end
	if shown == "" then shown = locale.none end
	if muted == "" then muted = locale.none end
	local user = client:getUser(channels[room.id].host)

	return {embeds = {{
		title = locale.chatInfoTitle:format(companion.name),
		color = blurple,
		description = locale.chatInfo:format(user.mentionString, hidden, shown, muted, commands)
	}}, ephemeral = ephemeral}
end)