local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, greeting)
	if greeting then
		lobbies[channel.id]:setGreeting(greeting)
		return "Companion greeting set", "ok", locale.greetingConfirm
	else
		lobbies[channel.id]:setGreeting()
		return "Companion greeting reset", "ok", locale.greetingReset
	end
end