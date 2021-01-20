local config = require "config"
local locale = require "locale"
local client = require "client"

local embeds = require "embeds/embeds"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local tps = require "funcs/truePositionSorting"
local channelType = require "discordia".enums.channelType

-- no embed data is saved, since this is non-interactive embed
embeds:new("matchmakingInfo", function (guild)
	local guildData = guilds[guild.id]
	
	local embed = {
		title = locale.matchmakingInfoTitle:format(guild.name),
		color = 0x00ffd5,
		description = #guildData.lobbies == 0 and locale.matchmakingNoInfo or locale.matchmakingInfo,
		fields = {}
	}
	
	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].isMatchmaking
	end), tps)
	
	local sortedLobbyData = {}
	for i, lobby in ipairs(sortedLobbies) do table.insert(sortedLobbyData, lobbies[lobby.id]) end
	
	for _, lobbyData in pairs(sortedLobbyData) do
		local target, pool = client:getChannel(lobbyData.target), 0
		table.insert(embed.fields, {
			name = client:getChannel(lobbyData.id).name,
			value = locale.matchmakingField:format(
				target and target.name or "default",
				lobbyData.template or "random",
				target.type == channelType.category and #target.voiceChannels or #lobbies[target.id].children
			),
			inline = true
		})
	end
	
	return embed
end)