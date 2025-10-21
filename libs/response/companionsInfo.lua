local client = require "client"

local lobbies = require "storage/lobbies"

local tps = require "utils/truePositionSort"
local insert = table.insert

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, target : Guild | GuildVoiceChannel) : table
local companionsInfo = response("companionsInfo", response.colors.blurple, function (locale, target)
	local components = {
		{
			type = componentType.textDisplay,
			content = string.format("## %s", target.name)
		}
	}

	local guild = target.guild or target
	local isChannel = not not target.guild

	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].companionTarget and not lobbies[voiceChannel.id].isMatchmaking
	end), tps)

	if not sortedLobbies or #sortedLobbies == 0 then
		insert(components, {
			type = componentType.textDisplay,
			content = localeHandler(locale, "companionsNoInfo")
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
		local target = client:getChannel(lobbyData.companionTarget)
		local logChannel = client:getChannel(lobbyData.companionLog)

		insert(components, {
			type = componentType.textDisplay,
			content = localeHandler(locale, "companionsField",
				target and target.name or "default",
				lobbyData.companionTemplate or "private-chat",
				logChannel and logChannel.name or localeHandler(locale, "none"),
				lobbyData.greeting or localeHandler(locale, "none")
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
				custom_id = "companion_view",
				options = options,
				placeholder = localeHandler(locale, "lobbyViewSelect")
			}}
		})
	end

	return components
end)

return companionsInfo