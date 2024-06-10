local locale = require "locale"
local client = require "client"
local embedHandler = require "handlers/embedHandler"

local guilds = require "storage/guilds"
local stats = require "handlers/storageHandler".stats

local black = embedHandler.colors.black

return embedHandler("ping", function (dt, guild, ephemeral)
	local guildData = guilds[guild.id]
	return {embeds = {{
		color = black,
		description = locale.ping:format(dt:toMilliseconds(),
			#client.guilds,
			stats.lobbies, #guildData.lobbies,
			stats.channels, guildData:channels(),
			stats.users, guildData:users())
	}}, ephemeral = ephemeral}
end)