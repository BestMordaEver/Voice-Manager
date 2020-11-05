local locale = require "locale"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local ratelimiter = require "utils/ratelimiter"
local templateInterpreter = require "utils/templateInterpreter"
local permission = require "discordia".enums.permission

ratelimiter("channelName", 2, 60*10)

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local channelData = channels[channel.id]
	local permissions = bitfield(channelData.parent.permissions)
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
		if channelData.parent.template and channelData.parent.template:match("%%rename%%") then
			success, err = channel:setName(templateInterpreter(
				channelData.parent.template, message.guild:getMember(message.author), channelData.position, message.content:match("name(.-)$")))
		else
			success, err = channel:setName(message.content:match("name(.-)$"))
		end
		
		if success then
			message:reply(locale.changedName.."\n"..locale[limit == 0 and "ratelimitReached" or "ratelimitRemaining"]:format(retryIn))
		else
			message:reply(locale.hostError)
		end
	end
	
	return success and "Successfully changed channel name" or ("Couldn't change channel name: "..err)
end