local client = require "client"
local localeHandler = require "locale/localeHandler"
local logger = require "logger"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local Overseer = require "overseer"
local metrics = require "telemetry/metrics"

local function transcriptTitle(channel, channelData)
	local parentName = localeHandler(channel.guild.preferred_locale, "noParent")
	if channelData and channelData.parent and channelData.parent.id then
		local parentChannel = client:getChannel(channelData.parent.id)
		if parentChannel then parentName = parentChannel.name end
	end

	return localeHandler(channel.guild.preferred_locale, "logName", channel.name, parentName)
end

local function sendTranscript(target, transcript, title)
	for index, payload in ipairs(transcript.payloads or {}) do
		local ok, err = target:send{
			content = index == 1 and title or nil,
			files = payload.files,
		}
		if not ok then return false, err, index end
	end

	return true
end

return function (channel) -- and make sure there are no traces!
	local lobbyData, channelData = lobbies[channel.id], channels[channel.id]
	local guildData = guilds[channel.guild.id]

	if lobbyData then
		guildData.lobbies:remove(channel.id)
		lobbyData:delete()
	end
	if channelData then
		local companion = client:getChannel(channelData.companion)
		local subscribers = channelData.logSubscribers
		local hasSubscribers = subscribers and next(subscribers) ~= nil
		local hasLogChannel = channelData.parent and channelData.parent.companionLog

		if hasLogChannel or hasSubscribers then
			local logChannel = hasLogChannel and client:getChannel(channelData.parent.companionLog) or nil
			Overseer.markRoomDeleted(channel)
			local transcript = Overseer.finalize(channel)
			if transcript and transcript.payloads and transcript.payloads[1] then
				local logName = transcriptTitle(channel, channelData)

				if hasLogChannel then
					if logChannel then
						local uploaded = true
						local ok, err, batch = sendTranscript(logChannel, transcript, logName)
						if not ok then
							logger:log(2, "GUILD %s ROOM %s: failed to upload transcript batch %d - %s", channel.guild.id, channel.id, batch or -1, err)
							uploaded = false
						end
						metrics.counter("voicemanager_overseer_transcripts_total", 1, {outcome = uploaded and "uploaded" or "upload_failed"})
					else
						logger:log(4, "GUILD %s ROOM %s: transcript finalized but log channel is missing", channel.guild.id, channel.id)
						metrics.counter("voicemanager_overseer_transcripts_total", 1, {outcome = "no_log_channel"})
					end
				end

				if hasSubscribers then
					for userID in pairs(subscribers) do
						local user = client:getUser(userID)
						local dm = user and user:getPrivateChannel() or nil
						if dm then
							local ok, err, batch = sendTranscript(dm, transcript, logName)
							if not ok then
								logger:log(4, "GUILD %s ROOM %s USER %s: failed to deliver transcript batch %d - %s", channel.guild.id, channel.id, userID, batch or -1, err)
							end
						else
							logger:log(4, "GUILD %s ROOM %s USER %s: transcript subscriber unavailable in DMs", channel.guild.id, channel.id, userID)
						end
					end
				end
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