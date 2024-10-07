local locale = require "locale/runtime/localeHandler"
local embedHandler = require "handlers/embedHandler"

local yellow = embedHandler.colors.yellow

---@overload fun(localeCarrier : table, line : textLine, ...? : string) : table
return embedHandler("warning", function (localeCarrier, msg, ...)
	return {embeds = {{
		title = locale(localeCarrier.locale, "embedWarning"),
		color = yellow,
		description = locale(localeCarrier.locale, msg, ...)
	}}, ephemeral = true}
end)