local helpEmbed = require "embeds/help"

local articles = {
	help = 0,
	lobby = 1,
	matchmaking = 2,
	companion = 3,
	room = 4,
	chat = 5,
	other = 6
}

return function (interaction)
	local command = interaction.option and interaction.option.value or "help"
	return command.." help message", helpEmbed(articles[command])
end