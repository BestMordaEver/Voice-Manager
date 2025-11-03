local client = require "client"
local localeHandler = require "locale/localeHandler"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local Overseer = require "utils/logWriter"

return function (channel) -- and make sure there are no traces!
	local lobbyData, channelData = lobbies[channel.id], channels[channel.id]
	local guildData = guilds[channel.guild.id]

	if lobbyData then
		guildData.lobbies:remove(channel.id)
		lobbyData:delete()
	end
	if channelData then
		local companion = client:getChannel(channelData.companion) or channel
		if companion then
			local companionID = companion.id
			if channelData.parent and channelData.parent.companionLog then
				local logChannel = client:getChannel(channelData.parent.companionLog)
				if logChannel then
					local log = Overseer.finalize(companionID)
					logChannel:send{
						content = localeHandler(channel.guild.preferred_locale,
							"logName",
							channel.name,
							channelData.parent and client:getChannel(channelData.parent.id).name or localeHandler(channel.guild.preferred_locale, "noParent")),
						file = {string.format("%s.txt", companionID), log}
					}
				end
			end

			if channel ~= companion then companion:delete() end
		end
		channelData:delete()
	end
	for lobbyData,_ in pairs(guildData.lobbies) do
		if lobbyData.target == channel.id then lobbyData:setTarget() end
		if lobbyData.companionTarget == channel.id then lobbyData:setCompanionTarget() end
	end
end