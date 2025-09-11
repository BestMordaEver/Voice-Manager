local helpResponse = require "response/help"

return function (interaction, page)
	if page then
		if page == "widget" then
			page = interaction.values[1]
		end

		interaction:update(helpResponse(true, interaction.locale, page))
		return "Help page switched"
	else
		local command = interaction.option and interaction.option.value or "help"
		return command.." help message", helpResponse(true, interaction.locale, command)
	end
end