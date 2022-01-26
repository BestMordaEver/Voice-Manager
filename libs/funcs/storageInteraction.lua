-- any interaction with database comes through here
-- it ensures that no statement is used by two threads at the same time
local config = require "config"
local client = require "client"
local logger = require "logger"

local Mutex = require "discordia".Mutex

local mutexes = {}

local pcallFunc = function (statement, ...) statement:reset():bind(...):step() end

local storageInteractionEvent = function (statement, ...)
	if not mutexes[statement] then
		mutexes[statement] = Mutex()
	end
	mutexes[statement]:lock()
	local ok, msg = xpcall(pcallFunc, debug.traceback, statement, ...)
	mutexes[statement]:unlock()
	if not ok then error(msg) end
end

return function (statement, logMsg)
	local success, failure = logMsg..": completed", logMsg..": failed"
	return function (...)
		local ok, msg = xpcall(storageInteractionEvent, debug.traceback, statement, ...)
		if ok then
			logger:log(5, success, ...)
		else
			logger:log(2, "%s", string.format(failure, ...) .. ": " .. msg)
			if config.stderr then
				client:getChannel(config.stderr):send(string.format(failure, ...) .. ": " .. msg)
			end
		end
	end
end