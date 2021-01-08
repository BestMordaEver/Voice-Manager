local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, capacity)
	capacity = tonumber(capacity)
	if capacity < 0 or capacity > 99 then
		message:reply(locale.capacityOOB)
		return "Capacity OOB"
	else
		lobbies[channel.id]:setCapacity(capacity)
		message:reply(locale.capacityConfirm:format(capacity))
		return "Lobby capacity set"
	end
end