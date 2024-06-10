local client = require "client"
local config = require "config"

local guilds = require "storage/guilds"

return function (guild) -- triggers whenever new guild appears in bot's scope
	guilds:store(guild.id)
	if config.guildFeed then
		client:getChannel(config.guildFeed):send((guild.name or "no name").." added me!\n")
	end
end