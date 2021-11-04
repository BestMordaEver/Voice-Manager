local client = require "client"
local logger = require "logger"
local locale = require "locale"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local Overseer = require "utils/logWriter"
local dialogue = require "utils/dialogue"

return function (channel) -- and make sure there are no traces!
	if dialogue[channel.id] then dialogue:clear(channel.id) end
	
	local lobbyData, channelData = lobbies[channel.id], channels[channel.id]
	local guildData = guilds[channel.guild.id]
	
	if lobbyData then
		guildData.lobbies:remove(channel.id)
		lobbyData:delete()
	end
	if channelData then
		local companion = client:getChannel(channelData.companion)
		if companion then
			if channelData.parent and channelData.parent.companionLog then
				local logChannel = client:getChannel(channelData.parent.companionLog)
				if logChannel then
					local log = Overseer:stop(companion)
					logChannel:send{
						content = locale.logName:format(channel.name, channelData.parent and client:getChannel(channelData.parent.id).name or locale.noParent),
						file = {string.format("%s.txt", companion.id), log}
					}
				end
			end
			
			companion:delete()
		end
		channelData:delete()
	end
	for lobbyData,_ in pairs(guildData.lobbies) do
		if lobbyData.target == channel.id then lobbyData:setTarget() end
		if lobbyData.companionTarget == channel.id then lobbyData:setCompanionTarget() end
	end
end