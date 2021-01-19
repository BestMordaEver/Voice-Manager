local locale = require "locale"
local channels = require "storage/channels"

return function (message, channel, newHost)
	local host = message.guild:getMember(newHost:match("%d+"))
	if host then
		channels[channel.id]:setHost(host.id)
		message:reply(locale.hostConfirm)
		return "Promoted a new host"
	else
		message:reply(locale.badUser)
		return "Didn't find mentioned user"
	end
end