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
	
	local overwrites = client:getChannel(channels[room.id].companion).permissionOverwrites:toArray(function(overwrite) return overwrite.type == "member" end)
	
	for _,overwrite in pairs(overwrites) do
		if Permissions(overwrite.allowedPermissions):has(permission.readMessages) then
			hidden = hidden..member.user.mentionString.." ,"
		end
		if Permissions(overwrite.deniedPermissions):has(permission.readMessages) then
			shown = shown..member.user.mentionString.." ,"
		end
		if Permissions(overwrite.deniedPermissions):has(permission.sendMessages) then
			muted = muted..member.user.mentionString.." ,"
		end
	end
	for name, _ in pairs(parent.permissions.bits) do
		if chatCommands[name] and parent.permissions:has(name) then commands = commands..chatCommands[name]..", " end
	end
	
	hidden = hidden == "" and locale.none or hidden:sub(1,-3)
	shown = shown == "" and locale.none or shown:sub(1,-3)
	muted = muted == "" and locale.none or muted:sub(1,-3)
	commands = commands == "" and locale.none or commands:sub(1,-3)
	
	local embed = {
		title = locale.chatInfoTitle:format(room.name),
		color = 6561661,
		description = locale.chatInfo:format(hidden, shown, muted, commands)
	}
	return embed
end)