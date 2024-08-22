local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local yellow = embedHandler.colors.yellow

return embedHandler("warning", function (localeCarrier, msg, ephemeral)
	return {embeds = {{
		title = locale(localeCarrier.locale, "embedWarning"),
		color = yellow,
		description = locale(localeCarrier.locale, msg)
	}}, ephemeral = ephemeral}
end)