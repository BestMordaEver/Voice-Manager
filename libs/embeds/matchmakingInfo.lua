local locale = require "locale"
local client = require "client"
local embedHandler = require "handlers/embedHandler"

local lobbies = require "handlers/storageHandler".lobbies

local tps = require "handlers/channelHandler".truePositionSort

local channelType = require "discordia".enums.channelType
local blurple = embedHandler.colors.blurple
local insert = table.insert

return embedHandler("matchmakingInfo", function (guild, channel, ephemeral)
	local sortedLobbies
	if channel then
		sortedLobbies = {lobbies[channel.id]}
	else
		---@diagnostic disable-next-line: undefined-field
		sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
			return lobbies[voiceChannel.id] and not lobbies[voiceChannel.id].isMatchmaking
		end), tps)
		for i,lobby in ipairs(sortedLobbies) do
			sortedLobbies[i] = lobbies[lobby.id]
		end
	end

	local embed = {
		title = locale.matchmakingInfoTitle:format(guild.name),
		color = blurple,
		description = #sortedLobbies == 0 and locale.matchmakingNoInfo or nil,
		fields = {}
	}

	for _, lobbyData in pairs(sortedLobbies) do
		local target = client:getChannel(lobbyData.target) or client:getChannel(lobbyData.id).category or
			{
				name = guild.name,
				type = channelType.category,
				voiceChannels = guild.voiceChannels:toArray(function (vc) return not vc.category end)
			}

		insert(embed.fields, {
			name = client:getChannel(lobbyData.id).name,
			value = locale.matchmakingField:format(
				target.name,
				lobbyData.template or "random",
				target.type == channelType.category and #target.voiceChannels or #lobbies[target.id].children
			),
			inline = true
		})
	end

	return {embeds = {embed}, ephemeral = ephemeral}
end)