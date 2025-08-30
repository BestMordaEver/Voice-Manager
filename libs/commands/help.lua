local helpEmbed = require "response/help"

return function (interaction, page)
	if page then
		interaction:update(helpEmbed(interaction, page))
		return "Help page switched"
	else
		local command = interaction.option and interaction.option.value or "help"
		return command.." help message", helpEmbed(interaction, command)
	end
end