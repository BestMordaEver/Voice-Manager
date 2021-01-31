local locale = require "locale"
local client = require "client"

local embeds = require "embeds/embeds"
local channels = require "storage/channels"
local guilds = require "storage/guilds"
local permission = require "discordia".enums.permission
local Permissions = require "discordia".Permissions

local chatCommands = {
	mute = "mute, unmute",
	moderate = "mute, unmute, hide, show",
	rename = "rename",
	manage = "rename, clear"
}

-- no embed data is saved, since this is non-interactive embed
embeds:new("chatInfo", function (room)
	local parent = channels[room.id].parent or guilds[room.guild.id]
	local hidden, shown, muted, commands = "","","",""
	
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
	for name, _ in pairs(parent.permissions.bits) do
		if chatCommands[name] and parent.permissions:has(name) then commands = commands..chatCommands[name]..", " end
	end
	
	if hidden == "" then hidden = locale.none end
	if shown == "" then shown = locale.none end
	if muted == "" then muted = locale.none end
	commands = commands == "" and locale.none or commands:sub(1,-3)
	
	local embed = {
		title = locale.chatInfoTitle:format(companion.name),
		color = 6561661,
		description = locale.chatInfo:format(hidden, shown, muted, commands)
	}
	return embed
end)