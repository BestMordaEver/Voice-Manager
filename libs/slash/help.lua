local commandOptionType = require "discordia".enums.applicationCommandOptionType

---@module "locale/slash/en-US"
local locale = require "locale/slash/localeHandler"

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
					name = locale.room,
					value = "room"
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