local config = require "config"
local locale = require "locale"

local embeds = require "embeds/embeds"
local guilds = require "storage/guilds"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"
local colors = embeds.colors

-- no embed data is saved, since this is non-interactive embed
embeds:new("serverInfo", function (guild)
	local guildData = guilds[guild.id]
	if not guild:getRole(guildData.role) then guildData:setRole(guild.defaultRole.id) end
	
	return {
		title = locale.serverInfoTitle:format(guild.name),
		color = colors.blurple,
		description = locale.serverInfo:format(
			guildData.prefix,
			guildData.permissions,
			guild:getRole(guildData.role).mentionString,
			#guildData.lobbies,
			channels:people(guild.id),
			channels:inGuild(guild.id),
			guildData.limit
		)
	}
end)