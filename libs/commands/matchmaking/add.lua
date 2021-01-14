local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel)
	lobbies(channel.id):setMatchmaking(true)
	message:reply(locale.matchmakingAddConfirm:format(channel.name))
	return "New matchmaking lobby added"
end