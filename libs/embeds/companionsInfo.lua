local locale = require "locale"
local client = require "client"
local embeds = require "embeds"

local lobbies = require "storage".lobbies

local tps = require "funcs/truePositionSorting"
local blurple = embeds.colors.blurple
local insert = table.insert

return embeds("companionsInfo", function (guild, channel, ephemeral)
	local sortedLobbies
	if channel then
		sortedLobbies = {lobbies[channel.id]}
	else
		---@diagnostic disable-next-line: undefined-field
		sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
			return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].companionTarget and not lobbies[voiceChannel.id].isMatchmaking
		end), tps)
		for i,lobby in ipairs(sortedLobbies) do
			sortedLobbies[i] = lobbies[lobby.id]
		end
	end

	local embed = {
		title = locale.companionsInfoTitle:format(guild.name),
		color = blurple,
		description = #sortedLobbies == 0 and locale.companionsNoInfo or nil,
		fields = {}
	}

	for _, lobbyData in pairs(sortedLobbies) do
		local target = client:getChannel(lobbyData.companionTarget)
		local logChannel = client:getChannel(lobbyData.companionLog)
		insert(embed.fields, {
			name = client:getChannel(lobbyData.id).name,
			value = locale.companionsField:format(
				target and target.name or "default",
				lobbyData.companionTemplate or "private-chat",
				logChannel and logChannel.name or locale.none,
				lobbyData.greeting or locale.none
			),
			inline = true
		})
	end

	return {embeds = {embed}, ephemeral = ephemeral}
end)