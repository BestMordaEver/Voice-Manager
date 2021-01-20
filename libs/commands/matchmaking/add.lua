local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel)
	lobbies(channel.id):setMatchmaking(true)
	return "New matchmaking lobby added", "ok", locale.matchmakingAddConfirm:format(channel.name)
end