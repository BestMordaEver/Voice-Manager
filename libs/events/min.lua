local client = require "client"
local config = require "config"

local mercy = require "utils/mercy"

local storage = require "handlers/storageHandler"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local stats = storage.stats

local status = require "handlers/statusHandler"

return function (date)
	channels:cleanup()

	storage.stats.lobbies = #lobbies
	storage.stats.channels = #channels
	storage.stats.users = channels:users()
	client:setActivity(status())

	if config.heartbeat then
		if mercy:tick() or (config.dailyreboot and stats.users == 0 and os.clock() > 86000) then mercy:kill() end
	end
end