local locale = require "locale"
local client = require "client"
local embeds = require "embeds"

local guilds = require "storage".guilds
local lobbies = require "storage".lobbies

local tps = require "funcs/truePositionSorting"

local blurple = embeds.colors.blurple
local insert = table.insert

return embeds("lobbiesInfo", function (guild, channel)
	local guildData = guilds[guild.id]

	local embed = {
		title = locale.lobbiesInfoTitle:format(guild.name),
		color = blurple,
		description = #guildData.lobbies == 0 and locale.lobbiesNoInfo or nil,
		fields = {}
	}

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

	for _, lobbyData in pairs(sortedLobbies) do
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

	return {embeds = {embed}}
end)