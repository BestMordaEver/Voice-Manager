local channels = require "handlers/storageHandler".channels

local enforceReservations = require "handlers/channelHandler".enforceReservations

return function (channel)
	if channel and channels[channel.id] then
		enforceReservations(channel)
	end
end