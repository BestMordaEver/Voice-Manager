local guilds = require "storage/guilds"

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, guild : Guild) : table
local serverInfo = response("serverInfo", response.colors.blurple, function (locale, guild)
	local guildData = guilds[guild.id]

	local roles = {}
	for roleID, _ in pairs(guildData.roles) do
		local role = guild:getRole(roleID)
		if role then
			table.insert(roles, role.mentionString)
		else
			guildData:removeRole(roleID)
		end
	end
	if #roles == 0 then roles[1] = localeHandler(locale, "none") end

	return {{
			type = componentType.textDisplay,
			content = localeHandler(locale, "serverInfo",
				guild.name,
				guildData.permissions,
				table.concat(roles, " "),
				#guildData.lobbies,
				guildData:users(),
				guildData:channels(),
				guildData.limit)
		}
	}
end)

return serverInfo