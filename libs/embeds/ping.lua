local locale = require "locale/runtime/localeHandler"
local client = require "client"
local embed = require "embeds/embed"

local guilds = require "storage/guilds"
local stats = require "storage/handler".stats

local black = embed.colors.black

return embed("ping", function (interaction, dt, guild, ephemeral)
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