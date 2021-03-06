local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, name)
	if name then
		name = name:lower()
		name = name:gsub("%s+", "%-")
	else
		name = "private-chat"
	end
	
	lobbies[channel.id]:setCompanionTemplate(name)
	return "Companion name template set", "ok", locale.nameConfirm:format(name)
end