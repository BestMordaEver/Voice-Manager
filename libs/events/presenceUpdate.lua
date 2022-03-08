local client = require "client"

local channels = require "storage".channels

local ratelimiter = require "utils/ratelimiter"
local templateInterpreter = require "funcs/templateInterpreter"

local awaiting = {}

ratelimiter:on("channelName", function (channelID)
	if awaiting[channelID] then
		local channel = client:getChannel(channelID)
		if channel then
			local name = templateInterpreter(channels[channelID].parent.template, channel.guild:getMember(channels[channelID].host), channels[channelID].position)

			if channel.name ~= name then
				channel:setName(name)
			end
		end
		awaiting[channelID] = nil
	end
end)

ratelimiter:on("companionName", function (companionID, channelID)
	if awaiting[companionID] then
		local channel, companion = client:getChannel(channelID), client:getChannel(companionID)

		if channel and companion then
			local name = templateInterpreter(channels[channelID].parent.companionTemplate,
				companion.guild:getMember(channels[channelID].host), channels[channelID].position):discordify()

			if companion.name ~= name then
				companion:setName(name)
			end
		end
		awaiting[companionID] = nil
	end
end)

return function (member)
	local channel = member.voiceChannel
	if not (channel and channels[channel.id] and channels[channel.id].host == member.user.id) then
		return		-- not host? gtfo
	end

	local channelData, parentData = channels[channel.id], channels[channel.id].parent
	local companion = client:getChannel(channelData.companion)

	if parentData then
		if parentData.template and parentData.template:match("%%game%(?.-%)?%%") then
			local name = templateInterpreter(parentData.template, member, channelData.position)

			if channel.name ~= name then	-- no need to waste ratelimits
				local limit = ratelimiter:limit("channelName", channel.id)
				if limit == -1 then
					awaiting[channelData.id] = true
				else
					channel:setName(name)
					awaiting[channel.id] = nil
				end
			end
		end

		if companion and parentData.companionTemplate and parentData.companionTemplate:match("%%game%(?.-%)?%%") then
			local name = templateInterpreter(parentData.companionTemplate, member, channelData.position):discordify()

			if companion.name ~= name then
				local limit = ratelimiter:limit("companionName", companion.id, channel.id)
				if limit == -1 then
					awaiting[companion.id] = true
				else
					companion:setName(name)
					awaiting[companion.id] = nil
				end
			end
		end
	end
end
