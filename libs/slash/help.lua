local commandOptionType = require "discordia".enums.applicationCommandOptionType
local locale = require "locale/localeHandler"

return {
	name = locale.help,
	description = locale.helpDesc,
	options = {
		{
			name = locale.helpArticle,
			description = locale.helpArticleDesc,
			type = commandOptionType.string,
			choices = {
				{
					name = locale.lobby,
					value = "lobby"
				},{
					name = locale.helpChoiceLobby,
					value = "lobbymore"
				},
				{
					name = locale.matchmaking,
					value = "matchmaking"
				},
				{
					name = locale.companion,
					value = "companion"
				},
				{
					name = locale.helpChoiceRoom1,
					value = "room"
				},{
					name = locale.helpChoiceRoom2,
					value = "roommore"
				},
				{
					name = locale.server,
					value = "server"
				},
				{
					name = locale.helpArticleOther,
					value = "other"
				}
			}
		}
	}
}