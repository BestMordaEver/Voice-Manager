local client = require "client"
local config = require "config"

local stats = require "handlers/storageHandler".stats

return function ()

	if config.statsFeed then
		client:getChannel(config.statsFeed):send(string.format([[servers - %d
lobbies - %d
channels - %d
users - %d]], #client.guilds, stats.lobbies, stats.channels, stats.users))
	end
end