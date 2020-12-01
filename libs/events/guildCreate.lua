local client = require "discordia".storage.client
local guilds = require "storage/guilds"
local config = require "config"

return function (guild) -- triggers whenever new guild appears in bot's scope
	guilds:add(guild.id)
	if config.guildFeed then
		client:getChannel(config.guildFeed):send((guild.name or "no name").." added me!\n")
	end
end