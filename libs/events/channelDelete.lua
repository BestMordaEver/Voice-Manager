local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

return function (channel) -- and make sure there are no traces!
	local lobbyData, channelData = lobbies[channel.id], channels[channel.id]
	local guildData = guilds[channel.guild.id]
	
	if lobbyData then
		guildData.lobbies:remove(channel.id)
		lobbyData:delete()
	end
	if channelData then
		channelData.parent:detachChild(channels[channel.id].position)
		channelData:delete()
		guildData.channels = guildData.channels - 1
	end
	for lobbyData,_ in pairs(guildData.lobbies) do
		if lobbyData.target == channel.id then lobbyData:setTarget() end
		if lobbyData.companionTarget == channel.id then lobbyData:setCompanionTarget() end
	end
end