local client = require "client"

local guilds = require "storage/guilds"
local stats = require "storage/handler".stats

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, dt : Date, guild : Guild) : table
local ping = response("ping", response.colors.black, function (locale, dt, guild)
	local guildData = guilds[guild.id]

	return {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "pingView", dt:toMilliseconds(),
			#client.guilds,
			stats.lobbies, #guildData.lobbies,
			stats.channels, guildData:channels(),
			stats.users, guildData:users())
		}
	}
end)

return ping