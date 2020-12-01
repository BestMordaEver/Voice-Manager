local discordia = require "discordia"
local config = require "config"
local client, logger = discordia.storage.client, discordia.storage.logger

return function (name, func)
	-- will be sent to emitter:on() style function
	-- name corresponds to event name
	return name, function (...)
		local success, err = xpcall(func, debug.traceback, ...)
		if not success then
			logger:log(1, "Error on %s: %s", name, err)
			if config.stderr then
				client:getChannel(config.stderr):sendf("Error on %s: %s", name, err)
			end
		end
	end
end