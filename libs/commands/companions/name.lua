local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, name)
	name = name:gsub(string.lower)
	name = name:gsub("%s+", "%-")
	lobbies[channel.id]:setCompanionTemplate(name)
	message:reply(locale.nameConfirm:format(name))
	return "Companion name template set"
end