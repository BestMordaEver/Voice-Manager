local locale = require "locale"
local dialogue = require "utils/dialogue"
local lobbies = require "storage/lobbies"

return function (message, channel)
	dialogue[message.author.id] = nil
	lobbies[channel.id]:delete()
	return "Lobby removed", "ok", locale.removeConfirm:format(channel.name)
end