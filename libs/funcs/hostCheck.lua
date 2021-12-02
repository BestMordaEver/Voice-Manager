local channels = require "storage/channels"
local permission = require "discordia".enums.permission

-- returns host's channel or error message if user is not a channel host
return function (message)
	local channel = message.member.voiceChannel

	if channel and channels[channel.id] and (channels[channel.id].host == message.author.id or message.member:hasPermission(channel, permission.administrator)) then
		return channel
	end
end