local client = require "client"
local logger = require "logger"
local locale = require "locale"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local logWriter = require "utils/logWriter"

return function (channel) -- and make sure there are no traces!
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
				logWriter.start(companion)
				local isOk, link = logWriter.finish(companion)
				if isOk then
					logChannel:sendf(locale.loggerLink,
						channel.name, channelData.parent and client:getChannel(channelData.parent.id).name or locale.noParent, link)
				else
					logChannel:sendf(locale.pastebinError, channel.name, channel.parent and client:getChannel(channel.parent.id).name or locale.noParent)
					logger:log(2, "Couldn't post to pastebin.com, see following error\n%s", link)
				end
			end
			
			companion:delete()
		end
		if type(channelData.parent) == "table" then channelData.parent:detachChild(channelData.position) end
		channelData:delete()
	end
	for lobbyData,_ in pairs(guildData.lobbies) do
		if lobbyData.target == channel.id then lobbyData:setTarget() end
		if lobbyData.companionTarget == channel.id then lobbyData:setCompanionTarget() end
	end
end