local heroesNeverDie = require "discordia".Emitter()
local commands = require "commands/init"

heroesNeverDie:on("shutdown", commands.shutdown)

local shutdown = function () heroesNeverDie:emit("shutdown") end -- ensures graceful shutdown

process:on('sigterm', shutdown)
process:on('sigint', shutdown)

local shards = {[0] = 3}

return {
	reset = function (shard)
		shards[shard] = 3
	end,

	tick = function ()
		local dead = false
		for shard, counter in pairs(shards) do
			shards[shard] = counter - 1
			if shards[shard] < 0 then dead = true end
		end

		return dead
	end,

	kill = shutdown
}