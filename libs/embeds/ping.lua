local locale = require "locale"
local client = require "client"
local embedHandler = require "handlers/embedHandler"

local storage = require "handlers/storageHandler"
local guilds = storage.guilds
local stats = storage.stats

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