local client = require "client"
local config = require "config"

local storage = require "storage"
local channels = storage.channels
local stats = storage.stats

local status = require "funcs/status"

return function (date)
	channels:cleanup()

	stats.lobbies = #storage.lobbies
	stats.channels = #storage.channels
	stats.users = storage.channels:users()
	client:setGame(status())

	if config.heartbeat then
		client:emit("sendHeartbeat")
	end
end