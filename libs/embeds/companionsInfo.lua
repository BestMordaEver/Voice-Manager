local locale = require "locale"
local client = require "client"

local embeds = require "embeds"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local tps = require "funcs/truePositionSorting"
local blurple = embeds.colors.blurple
local insert = table.insert

return embeds("companionsInfo", function (guild)
	local guildData = guilds[guild.id]

	local embed = {
		title = locale.companionsInfoTitle:format(guild.name),
		color = blurple,
		description = #guildData.lobbies == 0 and locale.companionsNoInfo or locale.lobbiesInfo,
		fields = {}
	}

---@diagnostic disable-next-line: undefined-field
	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].companionTarget
	end), tps)

	local sortedLobbyData = {}
	for i, lobby in ipairs(sortedLobbies) do insert(sortedLobbyData, lobbies[lobby.id]) end

	for _, lobbyData in pairs(sortedLobbyData) do
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

	return {embeds = {embed}}
end)