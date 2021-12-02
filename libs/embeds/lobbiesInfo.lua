local locale = require "locale"
local client = require "client"

local embeds = require "embeds/embeds"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local tps = require "funcs/truePositionSorting"
local colors = embeds.colors
local insert = table.insert

-- no embed data is saved, since this is non-interactive embed
embeds:new("lobbiesInfo", function (guild)
	local guildData = guilds[guild.id]
	local prefix = guilds[guild.id].prefix
	if prefix:match("%w$") then prefix = prefix .. " " end

	local embed = {
		title = locale.lobbiesInfoTitle:format(guild.name),
		color = colors.blurple,
		description = #guildData.lobbies == 0 and locale.lobbiesNoInfo:gsub("%%prefix%%", prefix) or locale.lobbiesInfo,
		fields = {}
	}

	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and not lobbies[voiceChannel.id].isMatchmaking
	end), tps)

	local sortedLobbyData = {}
	for i, lobby in ipairs(sortedLobbies) do insert(sortedLobbyData, lobbies[lobby.id]) end

	for _, lobbyData in pairs(sortedLobbyData) do
		local target = client:getChannel(lobbyData.target)
		if not guild:getRole(lobbyData.role) then lobbyData:setRole(guild.defaultRole.id) end

		insert(embed.fields, {
			name = client:getChannel(lobbyData.id).name,
			value = locale.lobbiesField:format(
				target and target.name or "default",
				lobbyData.template or "%nickname's% room",
				lobbyData.permissions,
				guild:getRole(lobbyData.role).mentionString,
				lobbyData.capacity or "default",
				lobbyData.companionTarget and "enabled" or "disabled",
				#lobbyData.children
			),
			inline = true
		})
	end

	return embed
end)