local config = require "config"
local locale = require "locale"

local embeds = require "embeds/embeds"
local guilds = require "storage/guilds"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"

-- no embed data is saved, since this is non-interactive embed
embeds:new("serverInfo", function (guild)
	local guildData = guilds[guild.id]
	
	return {
		title = locale.serverInfoTitle:format(guild.name),
		color = 6561661,
		description = locale.serverInfo:format(
			guildData.prefix,
			guildData.permissions,
			#guildData.lobbies,
			channels:people(guild.id),
			channels:inGuild(guild.id),
			guildData.limit
		)
	}
end)