local discordia = require "discordia"
local client = discordia.storage.client

local channels = require "storage/channels"
local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"

return function (guild) -- same but opposite
	guilds[guild.id]:delete()
	for _,channel in pairs(guild.voiceChannels) do 
		if channels[channel.id] then channels[channel.id]:delete() end 
		if lobbies[channel.id] then lobbies[channel.id]:delete() end
	end
	client:getChannel("676432067566895111"):send(guild.name.." removed me!\n")
end