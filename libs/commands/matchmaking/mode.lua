local locale = require "locale"
local lobbies = require "storage/lobbies"
local matchmakers = require "utils/matchmakers"

return function (message, channel, name)
	if not name then name = "random" end
	
	if matchmakers[name] then
		lobbies[channel.id]:setTemplate(name)
		return "Matchmaking mode set", "ok", locale.modeConfirm:format(name)
	else
		return "Bad matchmaking mode", "warning", locale.modeBadInput:format(name)
	end
end