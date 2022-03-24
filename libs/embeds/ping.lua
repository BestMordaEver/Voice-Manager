local locale = require "locale"
local client = require "client"
local embeds = require "embeds"

local storage = require "storage"
local guilds = storage.guilds
local stats = storage.stats

local black = embeds.colors.black

return embeds("ping", function (dt, guild)
	local guildData = guilds[guild.id]
	return {embeds = {{
		color = black,
		description = locale.ping:format(dt:toMilliseconds(),
			#client.guilds,
			stats.lobbies, #guildData.lobbies,
			stats.channels, guildData:channels(),
			stats.users, guildData:users())
	}}}
end)