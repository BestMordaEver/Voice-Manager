local client = require "client"

local lobbies = require "storage/lobbies"

local tps = require "utils/truePositionSort"
local insert = table.insert

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, target : Guild | GuildVoiceChannel) : table
local companionsInfo = response("companionsInfo", response.colors.blurple, function (locale, target)
	local sortedLobbies
	if target.guild then
		sortedLobbies = {lobbies[target.id]}
		target = target.guild
	else
		---@diagnostic disable-next-line: undefined-field
		sortedLobbies = table.sorted(target.voiceChannels:toArray(function(voiceChannel)
			return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].companionTarget and not lobbies[voiceChannel.id].isMatchmaking
		end), tps)
		for i,lobby in ipairs(sortedLobbies) do
			sortedLobbies[i] = lobbies[lobby.id]
		end
	end

	local components = {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "companionsInfoTitle", target.name)
		}
	}

	if #sortedLobbies == 0 then insert(components, {
		type = componentType.textDisplay,
		localeHandler(locale, "companionsNoInfo")
	}) end

	for _, lobbyData in ipairs(sortedLobbies) do
		local target = client:getChannel(lobbyData.companionTarget)
		local logChannel = client:getChannel(lobbyData.companionLog)

		insert(components, {
			type = componentType.textDisplay,
			name = string.format("**%s**", client:getChannel(lobbyData.id).name)
		})

		insert(components, {
			type = componentType.textDisplay,
			name = localeHandler(locale, "companionsField",
				target and target.name or "default",
				lobbyData.companionTemplate or "private-chat",
				logChannel and logChannel.name or localeHandler(locale, "none"),
				lobbyData.greeting or localeHandler(locale, "none")
			)
		})
	end

	return components
end)

return companionsInfo