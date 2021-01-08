local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel)
	lobbies[channel.id]:delete()
	message:reply(locale.removeConfirm:format(channel.name))
	return "Lobby removed"
end