local config = require "config"
local locale = require "locale"

local guilds = require "storage/guilds"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"

-- no embed data is saved, since this is non-interactive embed
return function (message)
	local guildData = guilds[message.guild.id]
	
	message:reply({embed = {
		title = locale.serverInfoTitle:format(message.guild.name),
		color = config.embedColor,
		description = locale.serverInfo:format(guildData.prefix, guildData.permissions, #guildData.lobbies, channels:people(message.guild.id), channels:inGuild(message.guild.id), guildData.limit)
	}})
end