local client = require "client"
local localeHandler = require "locale/localeHandler"
local logger = require "logger"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local Overseer = require "overseer"

return function (channel) -- and make sure there are no traces!
	local lobbyData, channelData = lobbies[channel.id], channels[channel.id]
	local guildData = guilds[channel.guild.id]

	if lobbyData then
		guildData.lobbies:remove(channel.id)
		lobbyData:delete()
	end
	if channelData then
		local companion = client:getChannel(channelData.companion)
		if channelData.parent and channelData.parent.companionLog then
			local logChannel = client:getChannel(channelData.parent.companionLog)
			local transcript = Overseer.finalize(channel)
			if logChannel and transcript and transcript.payloads[1] then
				local logName = localeHandler(channel.guild.preferred_locale,
					"logName",
					channel.name,
					channelData.parent and client:getChannel(channelData.parent.id).name or localeHandler(channel.guild.preferred_locale, "noParent"))
				for index, payload in ipairs(transcript.payloads) do
					local ok, err = logChannel:send{
						content = index == 1 and logName or nil,
						files = payload.files,
					}
					if not ok then
						logger:log(2, "GUILD %s ROOM %s: failed to upload transcript batch %d - %s", channel.guild.id, channel.id, index, err)
						break
					end
				end
			elseif transcript and not logChannel then
				logger:log(4, "GUILD %s ROOM %s: transcript finalized but log channel is missing", channel.guild.id, channel.id)
			end
			if transcript and transcript.cleanup then transcript.cleanup() end
		end

		if companion then companion:delete() end
		channelData:delete()
	end
	for lobbyData,_ in pairs(guildData.lobbies) do
		if lobbyData.target == channel.id then lobbyData:setTarget() end
		if lobbyData.companionTarget == channel.id then lobbyData:setCompanionTarget() end
	end
end