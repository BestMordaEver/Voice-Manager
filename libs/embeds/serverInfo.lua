local locale = require "locale/runtime/localeHandler"
local embedHandler = require "handlers/embedHandler"

local guilds = require "storage/guilds"

local blurple = embedHandler.colors.blurple

return embedHandler("serverInfo", function (interaction, ephemeral)
	local guild = interaction.guild
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
	if #roles == 0 then roles[1] = locale(interaction.locale, "none") end

	return {embeds = {{
		title = locale(interaction.locale, "serverInfoTitle", guild.name),
		color = blurple,
		description = locale(interaction.locale, "serverInfo",
			guildData.permissions,
			table.concat(roles, " "),
			#guildData.lobbies,
			guildData:users(),
			guildData:channels(),
			guildData.limit
		)
	}}, ephemeral = ephemeral}
end)