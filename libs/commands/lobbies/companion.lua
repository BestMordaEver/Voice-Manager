local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, toggle)
	if toggle ~= "enable" then toggle = "disable" end

	lobbies[channel.id]:setCompanionTarget(toggle == "enable" and "true" or nil) -- this is the best i can do :/
	message:reply(locale.companionToggle:format(toggle))
	return "Lobby companion "..toggle.."d"
end