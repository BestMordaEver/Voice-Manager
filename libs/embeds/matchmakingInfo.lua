local locale = require "locale"
local client = require "client"

local embeds = require "embeds"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local tps = require "funcs/truePositionSorting"
local channelType = require "discordia".enums.channelType
local blurple = embeds.colors.blurple
local insert = table.insert

return embeds("matchmakingInfo", function (guild)
	local guildData = guilds[guild.id]

	local embed = {
		title = locale.matchmakingInfoTitle:format(guild.name),
		color = blurple,
		description = #guildData.lobbies == 0 and locale.matchmakingNoInfo or locale.lobbiesInfo,
		fields = {}
	}

---@diagnostic disable-next-line: undefined-field
	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].isMatchmaking
	end), tps)

	local sortedLobbyData = {}
	for i, lobby in ipairs(sortedLobbies) do insert(sortedLobbyData, lobbies[lobby.id]) end

	for _, lobbyData in pairs(sortedLobbyData) do
		local target = client:getChannel(lobbyData.target) or client:getChannel(lobbyData.id).category
			or {name = client:getGuild(lobbyData.guildID).name,
				type = channelType.category,
				voiceChannels = client:getGuild(lobbyData.guildID).voiceChannels:toArray(function (vc) return not vc.category end)}
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

	return {embeds = {embed}}
end)