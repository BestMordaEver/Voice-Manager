local client = require "client"
local logger = require "logger"
local timer = require "timer"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local ratelimiter = require "utils/ratelimiter"
local templateInterpreter = require "funcs/templateInterpreter"

local awaiting = {}

local function nameGenerator(channel)
	local channelData = channels[channel.id]
	local template = channelData.parent.template
	return templateInterpreter(template, channel.guild:getMember(channelData.host), channelData.position,
		template:match("rename") and channel.name:match(template:gsub("%%rename%%", "(.-)"):gsub("%%.-%%",".-"), 1) or "")
end

ratelimiter:on(function (name, point)
	if name ~= "channelName" then
		return
	end
	
	local channel = client:getChannel(point)
	if not (channel and channel.name:match(channels[point].parent.template:gsub("%%.-%%", ".-"))) then
		return		-- edited beyond recognition by user? gtfo
	end
	
	if awaiting[point] then
		local name = nameGenerator(channel)
		if channel.name ~= name then
			channel:setName()
		end
		awaiting[point] = nil
	end
end)

return function (member)
	if not (member.voiceChannel and channels[member.voiceChannel.id] and channels[member.voiceChannel.id].host == member.user.id) then
		return		-- not host? gtfo
	end
	
	local channelData = channels[member.voiceChannel.id]
	if not (channelData.parent and channelData.parent.template:match("%%game%(?.-%)?%%")) then
		return		-- nothing to check? gtfo
	end
	
	local name = nameGenerator(member.voiceChannel)
	
	if not member.voiceChannel.name:match(channelData.parent.template:gsub("%%.-%%", ".-")) then
		return		-- edited beyond recognition by user? gtfo
	end
	
	if member.voiceChannel.name == name then
		return		-- no need to waste ratelimits
	end
	
	local limit, retryIn = ratelimiter:limit("channelName", member.voiceChannel.id)
	if limit == -1 then
		awaiting[channelData.id] = true
	else
		member.voiceChannel:setName(name)
		awaiting[channelData.id] = nil
	end
end