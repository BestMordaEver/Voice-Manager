local client = require "client"
local logger = require "logger"

local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local matchmakers = require "utils/matchmakers"

local enums = require "discordia".enums
local permission = enums.permission
local channelType = enums.channelType

return function (member, lobby)
	logger:log(4, "GUILD %s mLOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)

	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category
	if not target then return end

	local children

	if lobbies[target.id] then
		-- if target is another lobby - matchmake among its children
		children = lobby.guild.voiceChannels:toArray("position", function (channel)
			if channels[channel.id] then
				local parent = client:getChannel(channels[channel.id].parent.id)
				return (parent == target) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
			end
		end)
	else
		-- otherwise matchmake in the available channels of category
		children = target.voiceChannels:toArray("position", function (channel)
			return (channel ~= lobby) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
		end)
	end

	if #children == 1 then
		if member:setVoiceChannel(children[1]) then
			logger:log(4, "GUILD %s mLOBBY %s USER %s: matchmade", lobby.guild.id, lobby.id, target.id)
		end
	elseif #children > 1 then
		if member:setVoiceChannel((matchmakers[lobbies[lobby.id].template] or matchmakers.random)(children)) then
			logger:log(4, "GUILD %s mLOBBY %s USER %s: matchmade", lobby.guild.id, lobby.id, target.id)
		end
	else	-- if no available channels - create new or kick
		if target.type == channelType.voice then
			logger:log(4, "GUILD %s mLOBBY %s: no available room, delegating to LOBBY %s", lobby.guild.id, lobby.id, target.id)
			client:emit("voiceChannelJoin", member, target)
		else
			logger:log(4, "GUILD %s mLOBBY %s: no available room, gtfo", lobby.guild.id, lobby.id)
			member:setVoiceChannel()
		end
	end
end