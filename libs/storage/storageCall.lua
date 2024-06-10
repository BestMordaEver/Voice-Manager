-- any interaction with database comes through here
local config = require "config"
local client = require "client"
local logger = require "logger"

-- no statement is to be used by two threads at the same time
local Mutex = require "discordia".Mutex

local mutexes = {}
local pcallFunc = function (statement, ...) statement:reset():bind(...):step() end

-- all statements come through this logic
return function (statement, logMsg)
	-- setup
	-- prepare log messages
	local success, failure = logMsg..": completed", logMsg..": failed"

	-- create mutex for statement
	mutexes[statement] = Mutex()

	-- the actual logic
	return function (...)
		mutexes[statement]:lock()
		local ok, msg = xpcall(pcallFunc, debug.traceback, statement, ...)
		mutexes[statement]:unlock()

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