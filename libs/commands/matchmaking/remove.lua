local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel)
	lobbies[channel.id]:delete()
	return "Matchmaking lobby removed", "ok", locale.matchmakingRemoveConfirm:format(channel.name)
end