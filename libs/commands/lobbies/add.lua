local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel)
	lobbies(channel.id)
	return "New lobby added", "ok", locale.addConfirm:format(channel.name)
end