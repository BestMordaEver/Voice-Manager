local config = require "config"
local mercy = require "utils/mercy"

return function (shard, latency)
	if config.heartbeat then
		mercy.reset(shard)
	end
end