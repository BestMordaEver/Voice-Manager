local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, name)
	lobbies[channel.id]:setTemplate(name)
	message:reply(locale.nameConfirm:format(name))
	return "Lobby name template set"
end