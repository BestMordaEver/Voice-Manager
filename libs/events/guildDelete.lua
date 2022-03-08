local client = require "client"
local config = require "config"

local guilds = require "storage".guilds
local lobbies = require "storage".lobbies
local channels = require "storage".channels

return function (guild) -- same but opposite
	if guilds[guild.id] then guilds[guild.id]:delete() end
	for _,channel in pairs(guild.voiceChannels) do 
		if channels[channel.id] then channels[channel.id]:delete() end
		if lobbies[channel.id] then lobbies[channel.id]:delete() end
	end
	if config.guildFeed and guild.name then
		client:getChannel(config.guildFeed):send(guild.name.." removed me!\n")
	end
end