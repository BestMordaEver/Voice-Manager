local client = require "client"

local lobbies = require "storage/lobbies"

local tps = require "utils/truePositionSort"
local insert = table.insert

local enums = require "discordia".enums
local componentType = enums.componentType
local channelType = enums.channelType

local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, target : Guild | GuildVoiceChannel) : table
local matchmakingInfo = response("matchmakingInfo", response.colors.blurple, function (locale, target)
	local sortedLobbies
	if target.guild then
		sortedLobbies = {lobbies[target.id]}
		target = target.guild
	else
		---@diagnostic disable-next-line: undefined-field
		sortedLobbies = table.sorted(target.voiceChannels:toArray(function(voiceChannel)
			return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].isMatchmaking
		end), tps)
		for i,lobby in ipairs(sortedLobbies) do
			sortedLobbies[i] = lobbies[lobby.id]
		end
	end

	local components = {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "matchmakingInfoTitle", target.name)
		}
	}

	if #sortedLobbies == 0 then insert(components, {
		type = componentType.textDisplay,
		localeHandler(locale, "matchmakingNoInfo")
	}) end

	for _, lobbyData in ipairs(sortedLobbies) do
		local target = client:getChannel(lobbyData.target) or client:getChannel(lobbyData.id).category or
			{
				name = target.name,
				type = channelType.category,
				voiceChannels = target.voiceChannels:toArray(function (vc) return not vc.category end)
			}

		insert(components, {
			type = componentType.textDisplay,
			name = string.format("**%s**", client:getChannel(lobbyData.id).name)
		})

		insert(components, {
			type = componentType.textDisplay,
			name = localeHandler(locale, "matchmakingField",
				target.name,
				lobbyData.template or "random",
				target.type == channelType.category and #target.voiceChannels or #lobbies[target.id].children
			)
		})
	end

	return components
end)

return matchmakingInfo