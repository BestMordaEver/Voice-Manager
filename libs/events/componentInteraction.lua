local logger = require "logger"

local commands = require "commands/init"

return function (interaction)

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s: %s component triggered", interaction.guild.id, interaction.user.id, interaction.customId)
	else
		logger:log(4, "USER %s in DMs: %s component triggered", interaction.user.id, interaction.customId)
	end

	local command, primary, secondary = interaction.customId:match("^(.-)_(.-)_(.-)$")
	if secondary then
		secondary = tonumber(secondary) -- delete_row_1
	else
		command, primary = interaction.customId:match("^(.-)_(.-)$")
		primary = tonumber(primary) or primary -- help_1 or delete_nuke
	end

	return commands[command](interaction, primary, secondary)
end