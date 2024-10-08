local locale = require "locale/runtime/localeHandler"
local client = require "client"
local embedHandler = require "handlers/embedHandler"

local guilds = require "storage/guilds"
local stats = require "handlers/storageHandler".stats

local black = embedHandler.colors.black

return embedHandler("ping", function (interaction, dt, guild, ephemeral)
	local guildData = guilds[guild.id]
	return {embeds = {{
		color = black,
		description = locale(interaction.locale, "ping", dt:toMilliseconds(),
			#client.guilds,
			stats.lobbies, #guildData.lobbies,
			stats.channels, guildData:channels(),
			stats.users, guildData:users())
	}}, ephemeral = ephemeral}
end)