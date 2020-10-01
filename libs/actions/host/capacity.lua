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
	if not (message.guild:getMember(message.author):hasPermission(channel, permission.manageChannels) or permissions:has(permissions.bits.capacity)) then
		message:reply(locale.badHostPermission)
		return "Insufficient permissions"
	end
	
	local capacity = tonumber(message.content:match("capacity(.-)$"))
	if not capacity then return end
	
	local success, err = channel:setUserLimit(capacity)
	if success then
		if not message:addReaction("✅") then
			message:reply(locale.changedCapacity)
		end
	else
		message:reply(locale.hostError)
	end
	
	return success and "Successfully changed channel capacity" or ("Couldn't change channel capacity: "..err)
end