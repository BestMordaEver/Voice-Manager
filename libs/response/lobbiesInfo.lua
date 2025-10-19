local client = require "client"

local lobbies = require "storage/lobbies"

local tps = require "utils/truePositionSort"
local insert = table.insert

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, target : Guild | GuildVoiceChannel) : table
local lobbyInfo = response("lobbyInfo", response.colors.blurple, function (locale, target)
	local components = {
		{
			type = componentType.textDisplay,
			content = string.format("## %s", target.name)
		}
	}

	local guild = target.guild or target
	local isChannel = not not target.guild

	local sortedLobbies = table.sorted(guild.voiceChannels:toArray(function(voiceChannel)
		return lobbies[voiceChannel.id] and not lobbies[voiceChannel.id].isMatchmaking
	end), tps)

	if not sortedLobbies or #sortedLobbies == 0 then
		insert(components, {
			type = componentType.textDisplay,
			content = localeHandler(locale, "lobbiesNoInfo")
		})

		return components
	end

	if isChannel then
		local lobbyData = lobbies[target.id]
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
			content = localeHandler(locale, "lobbiesField",
				client:getChannel(lobbyData.id).name,
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
				custom_id = "lobby_view",
				options = options,
				placeholder = localeHandler(locale, "lobbyViewSelect")
			}}
		})
	end

	return components
end)

return lobbyInfo