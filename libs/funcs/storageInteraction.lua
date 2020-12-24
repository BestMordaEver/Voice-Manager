-- any interaction with database comes through here
-- it ensures that no statement is used by two threads at the same time
local config = require "config"
local client = require "client"
local Mutex = require "discordia".Mutex
local logger = require "logger"
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

return function (statement, success, failure)
	return function (...)
		local ok, msg = xpcall(storageInteractionEvent, debug.traceback, statement, ...)
		if ok then
			logger:log(4, "MEMORY: "..success, ...)
		else
			logger:log(2, "%s", string.format("MEMORY: "..failure, ...) .. ": " .. msg)
			if config.stderr then
				client:getChannel(config.stderr):send(string.format(failure, ...) .. ": " .. msg)
			end
		end
	end
end