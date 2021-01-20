local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, toggle)
	if toggle ~= "enable" then toggle = "disable" end

	lobbies[channel.id]:setCompanionTarget(toggle == "enable" and true or nil)
	return "Lobby companion "..toggle.."d", "ok", locale.companionToggle:format(toggle)
end