local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, capacity)
	capacity = tonumber(capacity)
	if capacity < 0 or capacity > 99 then
		return "Capacity OOB", "warning", locale.capacityOOB
	else
		lobbies[channel.id]:setCapacity(capacity)
		return "Lobby capacity set", "ok", locale.capacityConfirm:format(capacity)
	end
end