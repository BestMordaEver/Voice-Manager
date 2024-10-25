local locale = require "locale/runtime/localeHandler"
local embed = require "embeds/embed"

local green = embed.colors.green

---@overload fun(localeCarrier : table, line : textLine, ...? : string) : table
local ok = embed("ok", function (localeCarrier, msg, ...)
	return {embeds = {{
		title = locale(localeCarrier.locale, "embedOK"),
		color = green,
		description = locale(localeCarrier.locale, msg, ...)
	}}, ephemeral = true}
end)

return ok