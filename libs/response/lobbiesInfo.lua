local client = require "client"

local lobbies = require "storage/lobbies"

local tps = require "utils/truePositionSort"
local insert = table.insert

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, target : Guild | GuildVoiceChannel) : table
local lobbyInfo = response("lobbyInfo", response.colors.blurple, function (locale, target)
	local sortedLobbies
	if target.guild then
		sortedLobbies = {lobbies[target.id]}
		target = target.guild
	else
		---@diagnostic disable-next-line: undefined-field
		sortedLobbies = table.sorted(target.voiceChannels:toArray(function(voiceChannel)
			return lobbies[voiceChannel.id] and not lobbies[voiceChannel.id].isMatchmaking
		end), tps)
		for i,lobby in ipairs(sortedLobbies) do
			sortedLobbies[i] = lobbies[lobby.id]
		end
	end

	local components = {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "lobbiesInfoTitle", target.name)
		}
	}

	if #sortedLobbies == 0 then insert(components, {
		type = componentType.textDisplay,
		localeHandler(locale, "lobbiesNoInfo")
	}) end

	for _, lobbyData in ipairs(sortedLobbies) do
		local target = client:getChannel(lobbyData.target)
		local roles = {}
		for roleID in pairs(lobbyData.roles) do
			local role = target:getRole(roleID)
			if role then
				table.insert(roles, role.mentionString)
			else
				lobbyData:removeRole(roleID)
			end
		end
		if #roles == 0 then roles[1] = localeHandler(locale, "none") end

		insert(components, {
			type = componentType.textDisplay,
			name = string.format("**%s**", client:getChannel(lobbyData.id).name)
		})

		insert(components, {
			type = componentType.textDisplay,
			name = localeHandler(locale, "lobbiesField",
				target and target.name or "default",
				lobbyData.template or "%nickname's% room",
				lobbyData.permissions,
				table.concat(roles, " "),
				lobbyData.capacity or "default",
				lobbyData.bitrate or "default",
				lobbyData.companionTarget and "enabled" or "disabled",
				#lobbyData.children
			)
		})
	end

	return components
end)

return lobbyInfo