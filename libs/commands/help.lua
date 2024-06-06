local helpEmbed = require "embeds/help"

return function (interaction, page)
	if page then
		interaction:update(helpEmbed(page))
		return "Help page switched"
	else
		local command = interaction.option and interaction.option.value or "help"
		return command.." help message", helpEmbed(command)
	end
end