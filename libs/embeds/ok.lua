local locale = require "locale/runtime/localeHandler"
local embedHandler = require "handlers/embedHandler"

local green = embedHandler.colors.green

---@overload fun(localeCarrier : table, line : textLine, ...? : string) : table
local ok = embedHandler("ok", function (localeCarrier, msg, ...)
	return {embeds = {{
		title = locale(localeCarrier.locale, "embedOK"),
		color = green,
		description = locale(localeCarrier.locale, msg, ...)
	}}, ephemeral = true}
end)

return ok