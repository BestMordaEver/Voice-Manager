local locale = require "locale"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

return function (message, channel)
	if lobbies[channel.id] then
		return "Already registered", "warning", locale.lobbyDupe
	elseif channels[channel.id] then
		return "Rooms can't be lobbies", "warning", locale.channelDupe
	else
		lobbies(channel.id)
	end
	return "New lobby added", "ok", locale.addConfirm:format(channel.name)
end