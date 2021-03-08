local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, greeting)
	lobbies[channel.id]:setGreeting(greeting)
	return "Companion greeting set", "ok", locale.greetingConfirm:format(name)
end