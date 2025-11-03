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

	local components = {
		{
			type = componentType.textDisplay,
			content = string.format("## %s", target.name)
		}
	}

	local guild = target.guild or target
	local isChannel = not not target.guild

	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].isMatchmaking
	end), tps)

	if not sortedLobbies or #sortedLobbies == 0 then
		insert(components, {
			type = componentType.textDisplay,
			content = localeHandler(locale, "matchmakingNoInfo")
		})

		return components
	end

	if #sortedLobbies == 1 then
		isChannel = true
		target = sortedLobbies[1]
		components = {
			{
				type = componentType.textDisplay,
				content = string.format("## %s", target.name)
			}
		}
	end

	if isChannel then
		local lobbyData = lobbies[target.id]
		local target

		repeat
			target = client:getChannel(lobbyData.target) or client:getChannel(lobbyData.id).category or
				{
					name = target.name,
					type = channelType.category,
					voiceChannels = target.voiceChannels:toArray(function (vc) return not vc.category end)
				}

			if target.type == channelType.voice and not lobbies[target.id] then
				lobbyData:setTarget()
			else
				break
			end
		until false

		insert(components, {
			type = componentType.textDisplay,
			content = localeHandler(locale, "matchmakingField",
				target.name,
				lobbyData.template or "random",
				target.type == channelType.category and #target.voiceChannels or #lobbies[target.id].children
			)
		})
	end

	if not isChannel or #sortedLobbies > 1 then
		local options = {}

		for _, lobby in ipairs(sortedLobbies) do
			if lobby ~= target then
				insert(options, {
					label = lobby.name,
					value = lobby.id
				})
			end
		end

		insert(components, {
			type = componentType.row,
			components = {{
				type = componentType.stringSelect,
				custom_id = "matchmaking_view",
				options = options,
				placeholder = localeHandler(locale, "matchmakingViewSelect")
			}}
		})
	end

	return components
end)

return matchmakingInfo