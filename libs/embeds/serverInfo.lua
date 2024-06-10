local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local guilds = require "storage/guilds"

local blurple = embedHandler.colors.blurple

return embedHandler("serverInfo", function (guild, ephemeral)
	local guildData = guilds[guild.id]
	if not guild:getRole(guildData.role) then guildData:setRole(guild.defaultRole.id) end

	return {embeds = {{
		title = locale.serverInfoTitle:format(guild.name),
		color = blurple,
		description = locale.serverInfo:format(
			guildData.permissions,
			guild:getRole(guildData.role).mentionString,
			#guildData.lobbies,
			guildData:users(),
			guildData:channels(),
			guildData.limit
		)
	}}, ephemeral = ephemeral}
end)