local locale = require "locale"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local ratelimiter = require "utils/ratelimiter"
local permission = require "discordia".enums.permission

ratelimiter("channelName", 2, 60*10)

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local permissions = bitfield(lobbies[channels[channel.id].parent].permissions)
	if not (message.guild:getMember(message.author):hasPermission(channel, permission.manageChannels) or permissions:has(permissions.bits.name)) then
		message:reply(locale.badHostPermission)
		return "Insufficient permissions"
	end
	
	local limit, retryIn = ratelimiter:limit("channelName", channel.id)
	local success, err
	
	if limit == -1 then
		success, err = false, "ratelimit reached"
		message:reply(locale.ratelimitReached:format(retryIn))
	else
		success, err = channel:setName(message.content:match("name(.-)$"))
		if success then
			message:reply(locale.changedName.."\n"..locale[limit == 0 and "ratelimitReached" or "ratelimitRemaining"]:format(retryIn))
		else
			message:reply(locale.hostError)
		end
	end
	
	return success and "Successfully changed channel name" or ("Couldn't change channel name: "..err)
end