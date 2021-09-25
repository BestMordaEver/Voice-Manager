local client = require "client"
local logger = require "logger"
local timer = require "timer"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

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
	
	local channelData, parent = channels[channel.id], channels[channel.id].parent
	local companion = client:getChannel(channelData.companion)
	
	if not (parent and (
		(parent.template and parent.template:match("%%game%(?.-%)?%%"))
			or
		(parent.companionTemplate and parent.companionTemplate:match("%%game%(?.-%)?%%"))
		)) then
		return		-- nothing to check? gtfo
	end
	
	local name = templateInterpreter(parent.template, member, channelData.position)
		
	if channel.name ~= name then	-- no need to waste ratelimits
		local limit, retryIn = ratelimiter:limit("channelName", channel.id)
		if limit == -1 then
			awaiting[channelData.id] = true
		else
			channel:setName(name)
			awaiting[channel.id] = nil
		end
	end
	
	if companion then
		name = templateInterpreter(parent.companionTemplate, member, channelData.position):discordify()
			
		if companion.name ~= name then
			limit, retryIn = ratelimiter:limit("companionName", companion.id, channel.id)
			if limit == -1 then
				awaiting[companion.id] = true
			else
				companion:setName(name)
				awaiting[companion.id] = nil
			end
		end
	end
end