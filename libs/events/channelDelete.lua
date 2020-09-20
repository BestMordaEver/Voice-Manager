local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

return function (channel) -- and make sure there are no traces!
	if lobbies[channel.id] then
		guilds[channel.guild.id].lobbies:remove(channel.id)
		lobbies:remove(channel.id)
	end
	if channels[channel.id] then
		lobbies:detachChild(channel.id)
		channels:remove(channel.id)
		guilds[channel.guild.id].channels = guilds[channel.guild.id].channels - 1
	end
end