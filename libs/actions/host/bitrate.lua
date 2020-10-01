local discordia = require "discordia"
local locale = require "locale"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local permission = discordia.enums.permission

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local permissions = bitfield(lobbies[channels[channel.id].parent].permissions)
	if not (message.guild:getMember(message.author):hasPermission(channel, permission.manageChannels) or permissions:has(permissions.bits.bitrate)) then
		message:reply(locale.badHostPermission)
		return "Insufficient permissions"
	end
	
	local bitrate = tonumber(message.content:match("bitrate(.-)$"))
	if not bitrate then return end
	
	local success, err = channel:setBitrate( * 1000)
	if success then
		if not message:addReaction("✅") then
			message:reply(locale.changedBitrate)
		end
	else
		message:reply(locale.hostError)
	end
	
	return success and "Successfully changed channel bitrate" or ("Couldn't change channel bitrate: "..err)
end