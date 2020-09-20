local discordia = require "discordia"
local client = discordia.storage.client

local channels = require "storage/channels"
local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"

return function (guild) -- same but opposite
	guilds:remove(guild.id)
	for _,channel in pairs(guild.voiceChannels) do 
		if channels[channel.id] then channels:remove(channel.id) end 
		if lobbies[channel.id] then lobbies:remove(channel.id) end
	end
	client:getChannel("676432067566895111"):send(guild.name.." removed me!\n")
end