local client = require "client"
local config = require "config"

local mercy = require "utils/mercy"

local storage = require "handlers/storageHandler"
local channels = storage.channels
local stats = storage.stats

local status = require "handlers/statusHandler"

return function (date)
	channels:cleanup()

	stats.lobbies = #storage.lobbies
	stats.channels = #storage.channels
	stats.users = storage.channels:users()
	client:setGame(status())

	if config.heartbeat then
		if mercy:tick() or (config.dailyreboot and stats.users == 0 and os.clock() > 86000) then mercy:kill() end
	end
end