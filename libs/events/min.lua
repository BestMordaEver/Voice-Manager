local client = require "client"
local config = require "config"

local channels = require "storage".channels

local status = require "funcs/status"

return function (date)
	channels:cleanup()
	client:setGame(status())

	if config.heartbeat then
		client:emit("sendHeartbeat")
	end
end