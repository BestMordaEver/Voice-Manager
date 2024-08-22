local locale = require "locale/runtime/localeHandler"
local embedHandler = require "handlers/embedHandler"

local green = embedHandler.colors.green

return embedHandler("ok", function (localeCarrier, msg, ephemeral)
	return {embeds = {{
		title = locale(localeCarrier.locale, "embedOK"),
		color = green,
		description = locale(localeCarrier.locale, msg)
	}}, ephemeral = ephemeral}
end)