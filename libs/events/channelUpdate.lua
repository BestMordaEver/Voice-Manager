local channels = require "storage/channels"
local enforceReservations = require "funcs/enforceReservations"

return function (member, channel)
	if channel and channels[channel.id] then
		enforceReservations(channel)
	end
end