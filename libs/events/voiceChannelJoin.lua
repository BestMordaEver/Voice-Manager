local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local lobbyJoin = require "channelHandlers/lobbyJoin"
local matchmakingJoin = require "channelHandlers/matchmakingJoin"
local roomJoin = require "channelHandlers/roomJoin"
local channelJoin = require "channelHandlers/channelJoin"

local processing = {}

return function (member, channel)
	if channel then
		local processMutex = processing[channel.id]
		if processMutex then
			processMutex:lock()
		end

		local lobbyData = lobbies[channel.id]
		if lobbyData then
			if lobbyData.isMatchmaking then
				matchmakingJoin(member, channel)
			else
				lobbyJoin(member, channel)
			end
		elseif channels[channel.id] then
			if channels[channel.id].parentType == 3 then return end
			if channels[channel.id].host ~= member.user.id then roomJoin(member, channel) end
		elseif guilds[channel.guild.id].permissions.bitfield.value ~= 0 then
			channelJoin(member, channel)
		end

		if processMutex then
			processMutex:unlock()
		end
	end
end