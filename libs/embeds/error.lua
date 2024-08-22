local locale = require "locale/runtime/localeHandler"
local embedHandler = require "handlers/embedHandler"

local red = embedHandler.colors.red

return embedHandler("error", function (interaction, ephemeral)
	local errorReactions = locale(interaction.locale, "errorReaction")
	return {embeds = {{
		title = locale(interaction.locale, "embedError"),
		color = red,
		description = locale(interaction.locale, error, errorReactions[math.random(1, #errorReactions)])
	}}, ephemeral = ephemeral}
end)