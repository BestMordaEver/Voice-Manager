local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local categories = require "storage/categories"

return function (channel) -- and make sure there are no traces!
	local lobbyData, channelData, categoryData = lobbies[channel.id], channels[channel.id], categories[channel.id]
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
	if categoryData then
		if categoryData.parent then categoryData.parent:updateChild(self.child) end
		if categoryData.child then categoryData.child:updateParent(self.parent) end
		
		categoryData:delete()
	end
end