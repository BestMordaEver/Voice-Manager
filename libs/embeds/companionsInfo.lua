local locale = require "locale/runtime/localeHandler"
local client = require "client"
local embed = require "embeds/embed"

local lobbies = require "storage/lobbies"

local tps = require "handlers/channelHandler".truePositionSort
local blurple = embed.colors.blurple
local insert = table.insert

return embed("companionsInfo", function (interaction, channel, ephemeral)
	local sortedLobbies
	if channel then
		sortedLobbies = {lobbies[channel.id]}
	else
		---@diagnostic disable-next-line: undefined-field
		sortedLobbies = table.sorted(interaction.guild.voiceChannels:toArray(function(voiceChannel)
			return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].companionTarget and not lobbies[voiceChannel.id].isMatchmaking
		end), tps)
		for i,lobby in ipairs(sortedLobbies) do
			sortedLobbies[i] = lobbies[lobby.id]
		end
	end

	local embed = {
		title = locale(interaction.locale, "companionsInfoTitle", interaction.guild.name),
		color = blurple,
		description = #sortedLobbies == 0 and locale(interaction.locale, "companionsNoInfo") or nil,
		fields = {}
	}

	for _, lobbyData in pairs(sortedLobbies) do
		local target = client:getChannel(lobbyData.companionTarget)
		local logChannel = client:getChannel(lobbyData.companionLog)
		insert(embed.fields, {
			name = client:getChannel(lobbyData.id).name,
			value = locale(interaction.locale, "companionsField",
				target and target.name or "default",
				lobbyData.companionTemplate or "private-chat",
				logChannel and logChannel.name or locale(interaction.locale, "none"),
				lobbyData.greeting or locale(interaction.locale, "none")
			),
			inline = true
		})
	end

	return {embeds = {embed}, ephemeral = ephemeral}
end)