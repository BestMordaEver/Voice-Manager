local locale = require "locale"
local client = require "client"
local embedHandler = require "handlers/embedHandler"

local lobbies = require "storage/lobbies"

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
		local roles = {}
		for roleID, _ in pairs(lobbyData.roles) do
			local role = guild:getRole(roleID)
			if role then
				table.insert(roles, role.mentionString)
			else
				lobbyData:removeRole(roleID)
			end
		end
		if #roles == 0 then roles[1] = guild.defaultRole.mentionString end

		insert(embed.fields, {
			name = client:getChannel(lobbyData.id).name,
			value = locale.lobbiesField:format(
				target and target.name or "default",
				lobbyData.template or "%nickname's% room",
				lobbyData.permissions,
				table.concat(roles, " "),
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