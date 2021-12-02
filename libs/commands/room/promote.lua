local client = require "client"
local locale = require "locale"
local channels = require "storage/channels"
local hostCheck = require "funcs/hostCheck"

return function (message, newHost)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end

	local users = message.mentionedUsers:toArray(function (user) return user ~= client.user end)
	newHost = users[1] or client:getUser(newHost:match("%d+"))

	if newHost then
		if message.guild:getMember(newHost).voiceChannel == channel then
			channels[channel.id]:setHost(newHost.id)
			return "Promoted a new host", "ok", locale.hostConfirm:format(newHost.mentionString)
		else
			return "Can't promote person not in a room", "warning", locale.badNewHost
		end
	else
		return "Didn't find mentioned user", "warning", locale.badUser
	end
end