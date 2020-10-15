local discordia = require "discordia"
local locale = require "locale"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local permission = discordia.enums.permission

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local permissions = bitfield(channels[channel.id].parent.permissions)
	if not (message.guild:getMember(message.author):hasPermission(channel, permission.manageChannels) or permissions:has(permissions.bits.capacity)) then
		message:reply(locale.badHostPermission)
		return "Insufficient permissions"
	end
	
	local capacity = tonumber(message.content:match("resize(.-)$"))
	if not capacity then return end
	
	local success, err = channel:setUserLimit(capacity)
	if success then
		if not message:addReaction("✅") then
			message:reply(locale.channelResized)
		end
	else
		message:reply(locale.hostError)
	end
	
	return success and "Successfully resized channel" or ("Couldn't resize channel: "..err)
end