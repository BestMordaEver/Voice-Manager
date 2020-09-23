local locale = require "locale"
local channels = require "storage/channels"

-- returns host's channel or error message if user is not a channel host
return function (message)
	if not message.guild then
		message:reply(locale.noID)
		return "Host action in DMs"
	end
	
	local channel = message.guild:getMember(message.author).voiceChannel
	
	if not (channel and channels[channel.id] and channels[channel.id].host == message.author.id) then
		message:reply(locale.notHost)
		return "Not a host"
	end
	
	return channel
end