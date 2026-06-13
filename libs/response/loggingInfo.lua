local client = require "client"

local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"

local offset = require "utils/offset"
local tps = require "utils/truePositionSort"
local insert = table.insert

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/localeHandler"
local response = require "response/response"

local function header(locale, target, guildData)
	return {
		{
			type = componentType.textDisplay,
			content = string.format("## %s", target.name)
		},
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "loggingOffsetField",
				offset.format(guildData and guildData.logTimeOffset or 0))
		}
	}
end

---@overload fun(ephemeral : boolean, locale : localeName, target : Guild | GuildVoiceChannel) : table
local loggingInfo = response("loggingInfo", response.colors.blurple, function (locale, target)
	local guild = target.guild or target
	local guildData = guilds[guild.id]
	local isChannel = not not target.guild

	local components = header(locale, target, guildData)

	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and lobbies[voiceChannel.id].companionLog and not lobbies[voiceChannel.id].isMatchmaking
	end), tps)

	if not sortedLobbies or #sortedLobbies == 0 then
		insert(components, {
			type = componentType.textDisplay,
			content = localeHandler(locale, "loggingNoInfo")
		})

		return components
	end

	if #sortedLobbies == 1 then
		isChannel = true
		target = sortedLobbies[1]
		components = header(locale, target, guildData)
	end

	if isChannel then
		local lobbyData = lobbies[target.id]
		local logChannel = lobbyData and client:getChannel(lobbyData.companionLog)

		insert(components, {
			type = componentType.textDisplay,
			content = localeHandler(locale, "loggingField",
				logChannel and logChannel.name or localeHandler(locale, "none"))
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
				custom_id = "logging_view",
				options = options,
				placeholder = localeHandler(locale, "lobbyViewSelect")
			}}
		})
	end

	return components
end)

return loggingInfo
