local helpResponse = require "response/help"

return function (interaction, page)
	if page then
		if page == "widget" then
			page = interaction.values[1]
		end
	else
		page = interaction.option and interaction.option.value or "help"
	end
	return page.." help message", helpResponse(true, interaction.locale, page)
end