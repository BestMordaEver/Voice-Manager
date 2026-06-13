local B = require "slash/builders"
local locale = require "locale/localeHandler"

return {
	name = locale.help,
	description = locale.helpDesc,
	options = {
		B.string(locale.helpArticle, locale.helpArticleDesc, {
			choices = {
				{name = locale.lobby,            value = "lobby"},
				{name = locale.helpChoiceLobby1, value = "lobbymore"},
				{name = locale.helpChoiceLobby2, value = "lobbyplacement"},
				{name = locale.matchmaking,      value = "matchmaking"},
				{name = locale.companion,        value = "companion"},
				{name = locale.logging,          value = "logging"},
				{name = locale.helpChoiceRoom1,  value = "room"},
				{name = locale.helpChoiceRoom2,  value = "roommore"},
				{name = locale.server,           value = "server"},
				{name = locale.helpArticleOther, value = "other"},
			}
		})
	}
}