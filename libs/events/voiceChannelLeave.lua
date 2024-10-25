local channels = require "storage/channels"

local roomEmpty = require "channelHandlers/roomEmpty"
local roomReset = require "channelHandlers/roomReset"
local passwordCompleted = require "channelHandlers/passwordCompleted"
local memberLeft = require "channelHandlers/memberLeft"

return function (member, channel) -- now remove the unwanted corpses!
	local channelData = channel and channels[channel.id]
	if channelData then
		if #channel.connectedMembers == 0 then
			if channelData.parentType == 0 then
				roomEmpty(channel)
			elseif channelData.parentType == 3 then
				passwordCompleted(channel, member)
			else
				roomReset(channel)
			end
		else
			memberLeft(channel, member)
		end
	end
end