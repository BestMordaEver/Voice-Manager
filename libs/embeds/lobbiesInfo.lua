local locale = require "locale"
local client = require "client"
local embedHandler = require "handlers/embedHandler"

local lobbies = require "handlers/storageHandler".lobbies

local tps = require "handlers/channelHandler".truePositionSort

local blurple = embedHandler.colors.blurple
local insert = table.insert

return embedHandler("lobbiesInfo", function (guild, channel, ephemeral)
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
		title = locale.lobbiesInfoTitle:format(guild.name),
		color = blurple,
		description = #sortedLobbies == 0 and locale.lobbiesNoInfo or nil,
		fields = {}
	}

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
				lobbyData.bitrate or "default",
				lobbyData.companionTarget and "enabled" or "disabled",
				#lobbyData.children
			),
			inline = true
		})
	end

	return {embeds = {embed}, ephemeral = ephemeral}
end)