local locale = require "locale"
local embeds = require "embeds"

local guilds = require "storage/guilds"
local channels = require "storage/channels"

local blurple = embeds.colors.blurple

return embeds("serverInfo", function (guild)
	local guildData = guilds[guild.id]
	if not guild:getRole(guildData.role) then guildData:setRole(guild.defaultRole.id) end

	return {embeds = {{
		title = locale.serverInfoTitle:format(guild.name),
		color = blurple,
		description = locale.serverInfo:format(
			guildData.prefix,
			guildData.permissions,
			guild:getRole(guildData.role).mentionString,
			#guildData.lobbies,
			channels:people(guild.id),
			channels:inGuild(guild.id),
			guildData.limit
		)
	}}}
end)