local channels = require "storage".channels

local enforceReservations = require "funcs/enforceReservations"

return function (channel)
	if channel and channels[channel.id] then
		enforceReservations(channel)
	end
end