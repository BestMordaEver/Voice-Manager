local config = require "config"
local locale = require "locale"
local client = require "client"

local embeds = require "embeds/embeds"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local tps = require "funcs/truePositionSorting"

-- no embed data is saved, since this is non-interactive embed
embeds:new("companionsInfo", function (guild)
	local guildData = guilds[guild.id]
	
	local embed = {
		title = locale.companionsInfoTitle:format(guild.name),
		color = 6561661,
		description = #guildData.lobbies == 0 and locale.companionsNoInfo or locale.lobbiesInfo,
		fields = {}
	}
	
	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].companionTarget
	end), tps)
	
	local sortedLobbyData = {}
	for i, lobby in ipairs(sortedLobbies) do table.insert(sortedLobbyData, lobbies[lobby.id]) end
	
	for _, lobbyData in pairs(sortedLobbyData) do
		local target = client:getChannel(lobbyData.companionTarget)
		table.insert(embed.fields, {
			name = client:getChannel(lobbyData.id).name,
			value = locale.companionsField:format(
				target and target.name or "default",
				lobbyData.companionTemplate or "private-chat",
				lobbyData.greeting or locale.none
			),
			inline = true
		})
	end
	
	return embed
end)