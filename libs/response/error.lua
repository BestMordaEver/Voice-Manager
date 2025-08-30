local locale = require "locale/runtime/localeHandler"
local embed = require "response/embed"

local red = embed.colors.red

return embed("error", function (interaction)
	local errorReactions = locale(interaction.locale, "errorReaction")
	return {embeds = {{
		title = locale(interaction.locale, "embedError"),
		color = red,
		description = locale(interaction.locale, "error", errorReactions[math.random(1, #errorReactions)])
	}}, ephemeral = true}
end)