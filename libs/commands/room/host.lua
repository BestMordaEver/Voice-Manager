local client = require "client"
local locale = require "locale"
local channels = require "storage/channels"

return function (message)
	local host = client:getUser(channels[message.member.voiceChannel.id].host)

	if host then
		return "Pinged the host", "ok", locale.hostIdentify:format(host.mentionString)
	else
		return "Didn't find host", "warning", locale.badHost
	end
end