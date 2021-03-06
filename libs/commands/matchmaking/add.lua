local locale = require "locale"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

return function (message, channel)
	if lobbies[channel.id] then
		return "Already registered", "warning", locale.lobbyDupe
	elseif channels[channel.id] and not channels[channel.id].isPersistent then
		return "Rooms can't be lobbies", "warning", locale.channelDupe
	else
		lobbies(channel.id):setMatchmaking(true)
	end
	return "New matchmaking lobby added", "ok", locale.matchmakingAddConfirm:format(channel.name)
end