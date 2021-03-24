local config = require "config"
local client = require "client"
local logger = require "logger"

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
			if name == "ready" then
				process:exit()
			end
		end
	end
end