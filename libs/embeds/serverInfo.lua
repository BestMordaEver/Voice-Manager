local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local guilds = require "storage/guilds"

local blurple = embedHandler.colors.blurple

return embedHandler("serverInfo", function (guild, ephemeral)
	local guildData = guilds[guild.id]

	local roles = {}
	for roleID, _ in pairs(guildData.roles) do
		local role = guild:getRole(roleID)
		if role then
			table.insert(roles, role.mentionString)
		else
			guildData:removeRole(roleID)
		end
	end
	if #roles == 0 then roles[1] = guild.defaultRole.mentionString end

	return {embeds = {{
		title = locale.serverInfoTitle:format(guild.name),
		color = blurple,
		description = locale.serverInfo:format(
			guildData.permissions,
			table.concat(roles, " "),
			#guildData.lobbies,
			guildData:users(),
			guildData:channels(),
			guildData.limit
		)
	}}, ephemeral = ephemeral}
end)