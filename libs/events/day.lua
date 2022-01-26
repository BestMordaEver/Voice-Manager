local client = require "client"
local config = require "config"

local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local s, l, c, p

return function ()
	if not s then
		s, l, c, p = #client.guilds, #lobbies, #channels, channels:people()
	end

	if config.statsFeed then
		client:getChannel(config.statsFeed):send(string.format([[Servers: %d (%+d)
Lobbies: %d (%+d)
Channels: %d (%+d)
Users: %d (%+d)]], #client.guilds, #client.guilds - s, #lobbies, #lobbies - l, #channels, #channels - c, channels:people(), channels:people() - p))
	end

	s, l, c, p = #client.guilds, #lobbies, #channels, channels:people()
end