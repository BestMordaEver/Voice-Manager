local locale = require "locale"
local client = require "client"

local embeds = require "embeds/embeds"
local channels = require "storage/channels"
local availableCommands = require "funcs/availableCommands"
local permission = require "discordia".enums.permission
local Permissions = require "discordia".Permissions

-- no embed data is saved, since this is non-interactive embed
embeds:new("chatInfo", function (room)
	local hidden, shown, muted = "","",""
	
	local companion = client:getChannel(channels[room.id].companion)
	
	for _,overwrite in pairs(companion.permissionOverwrites:toArray(function(overwrite) return overwrite.type == "member" end)) do
		if Permissions(overwrite.allowedPermissions):has(permission.readMessages) then
			hidden = hidden..overwrite:getObject().user.mentionString.." "
		end
		if Permissions(overwrite.deniedPermissions):has(permission.readMessages) then
			shown = shown..overwrite:getObject().user.mentionString.." "
		end
		if Permissions(overwrite.deniedPermissions):has(permission.sendMessages) then
			muted = muted..overwrite:getObject().user.mentionString.." "
		end
	end
	
	local _, commands = availableCommands(room)
	
	if hidden == "" then hidden = locale.none end
	if shown == "" then shown = locale.none end
	if muted == "" then muted = locale.none end
	
	return {
		title = locale.chatInfoTitle:format(companion.name),
		color = 6561661,
		description = locale.chatInfo:format(hidden, shown, muted, commands)
	}
end)