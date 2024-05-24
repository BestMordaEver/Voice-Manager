local commandOptionType = require "discordia".enums.applicationCommandOptionType

return {
	name = "help",
	description = "A help command!",
	options = {
		{
			name = "article",
			description = "Which help article do you need?",
			type = commandOptionType.string,
			choices = {
				{
					name = "lobby",
					value = "lobby"
				},
				{
					name = "matchmaking",
					value = "matchmaking"
				},
				{
					name = "companion",
					value = "companion"
				},
				{
					name = "room",
					value = "room"
				},
				{
					name = "chat",
					value = "chat"
				},
				{
					name = "server",
					value = "server"
				},
				{
					name = "misc",
					value = "misc"
				}
			}
		}
	}
}