local heroesNeverDie = require "discordia".Emitter()
local actions = require "./actions.lua"

local aliveTracker = 5

heroesNeverDie:on("shutdown", actions.shutdown)

local shutdown = function () heroesNeverDie:emit("shutdown") end -- ensures graceful shutdown

process:on('sigterm', shutdown)
process:on('sigint', shutdown)

return {
	reset = function ()
		aliveTracker = 5
	end,
	
	tick = function ()
		aliveTracker = aliveTracker - 1
		return aliveTracker < 0
	end,
	
	kill = shutdown
}