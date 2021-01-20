local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel)
	lobbies[channel.id]:delete()
	return "Lobby removed", "ok", locale.removeConfirm:format(channel.name)
end