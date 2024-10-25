local locale = require "locale/runtime/localeHandler"
local client = require "client"
local embed = require "embeds/embed"

local lobbies = require "storage/lobbies"

local tps = require "channelHandlers/truePositionSort"

local channelType = require "discordia".enums.channelType
local blurple = embed.colors.blurple
local insert = table.insert

return embed("matchmakingInfo", function (interaction, channel, ephemeral)
	local sortedLobbies
	if channel then
		sortedLobbies = {lobbies[channel.id]}
	else
		---@diagnostic disable-next-line: undefined-field
		sortedLobbies = table.sorted(interaction.guild.voiceChannels:toArray(function(voiceChannel)
			return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].isMatchmaking
		end), tps)
		for i,lobby in ipairs(sortedLobbies) do
			sortedLobbies[i] = lobbies[lobby.id]
		end
	end

	local embed = {
		title = locale(interaction.locale, "matchmakingInfoTitle", interaction.guild.name),
		color = blurple,
		description = #sortedLobbies == 0 and locale(interaction.locale, "matchmakingNoInfo") or nil,
		fields = {}
	}

	for _, lobbyData in pairs(sortedLobbies) do
		local target = client:getChannel(lobbyData.target) or client:getChannel(lobbyData.id).category or
			{
				name = interaction.guild.name,
				type = channelType.category,
				voiceChannels = interaction.guild.voiceChannels:toArray(function (vc) return not vc.category end)
			}

		insert(embed.fields, {
			name = client:getChannel(lobbyData.id).name,
			value = locale(interaction.locale, "matchmakingField",
				target.name,
				lobbyData.template or "random",
				target.type == channelType.category and #target.voiceChannels or #lobbies[target.id].children
			),
			inline = true
		})
	end

	return {embeds = {embed}, ephemeral = ephemeral}
end)