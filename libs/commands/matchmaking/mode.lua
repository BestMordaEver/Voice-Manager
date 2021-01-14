local locale = require "locale"
local lobbies = require "storage/lobbies"
local matchmakers = require "utils/matchmakers"

return function (message, channel, name)
	if matchmakers[name] then
		lobbies[channel.id]:setTemplate(name)
		message:reply(locale.modeConfirm:format(name))
		return "Lobby name template set"
	else
		message:reply(locale.modeBadInput:format(name))
		return "Lobby name template set"
	end
end