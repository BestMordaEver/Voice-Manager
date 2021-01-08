local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel)
	lobbies(channel.id)
	message:reply(locale.addConfirm:format(channel.name))
	return "New lobby added"
end