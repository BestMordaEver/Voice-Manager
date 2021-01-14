local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel)
	lobbies[channel.id]:delete()
	message:reply(locale.matchmakingRemoveConfirm:format(channel.name))
	return "Matchmaking lobby removed"
end