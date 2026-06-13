-- any interaction with database comes through here
local config = require "config"
local client = require "client"
local logger = require "logger"

local metrics = require "telemetry/metrics"

-- one mutex per database connection
local Mutex = require "discordia".Mutex

local dbMutexes = setmetatable({}, {
	__index = function (self, db)
		self[db] = Mutex()
		return self[db]
	end
})
local pcallFunc = function (statement, ...) statement:reset():bind(...):step() end

-- all statements come through this logic
return function (statement, logMsg, db)
	-- setup
	-- prepare log messages
	local success, failure = logMsg..": completed", logMsg..": failed"

	-- the actual logic
	return function (...)
		local mutex = dbMutexes[db]
		mutex:lock()
		local ok, msg = xpcall(pcallFunc, debug.traceback, statement, ...)
		mutex:unlock()

		metrics.counter("voicemanager_db_writes_total", 1, {outcome = ok and "success" or "error"})

		if ok then
			logger:log(5, success, ...)
		else
			logger:log(2, "%s: %s", string.format(failure, ...), msg)
			if config.stderr then
				client:getChannel(config.stderr):sendf("%s: %s", string.format(failure, ...), msg)
			end
		end
	end
end