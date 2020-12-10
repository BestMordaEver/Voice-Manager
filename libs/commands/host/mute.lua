local discordia = require "discordia"
local locale = require "locale"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local client = discordia.storage.client
local permission = discordia.enums.permission

local actions = {
	add = function (channel, message)
		if not channels[channel.id].muted then channels[channel.id].muted = {} end
		for _, user in pairs(message.mentionedUsers) do
			if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):denyPermissions(permission.speak) then return end
			channels[channel.id].muted[user] = true
		end
		return true
	end,
	
	remove = function (channel, message)
		if not channels[channel.id].muted then return end
		for _, user in pairs(message.mentionedUsers) do
			if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.speak) then return end
			channels[channel.id].muted[user] = nil
		end
		return true
	end,
	
	clear = function (channel)
		if not channels[channel.id].muted then return end
		for user, _ in pairs(channels[channel.id].muted) do
			if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.speak) then return end
		end
		channels[channel.id].muted = nil
		return true
	end
}

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local permissions = bitfield(channels[channel.id].parent.permissions)
	if not permissions:has(permissions.bits.mute) then
		message:reply(locale.badHostPermission)
		return "Insufficient permissions"
	end
	
	local command = message.content:match("mute%s*(%a*)"):lower()
	if message.content:lower():match("unmute") then
		command = "remove"
	elseif not actions[command] then
		command = "add"
	end
	
	if actions[command](channel, message) then
		message:addReaction("✅")
		return "Sucessfully processed mute"
	else
		message:reply(locale.hostError)
		return "Couldn't process mute"
	end
end