local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, name)
	if not name then name = "%nickname's% room" end
	lobbies[channel.id]:setTemplate(name)
	return "Lobby name template set", "ok", locale.nameConfirm:format(name)
end