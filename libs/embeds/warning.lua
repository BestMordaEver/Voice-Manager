local locale = require "locale/runtime/localeHandler"
local embed = require "embeds/embed"

local yellow = embed.colors.yellow

---@overload fun(localeCarrier : table, line : textLine, ...? : string) : table
local warning = embed("warning", function (localeCarrier, msg, ...)
	return {embeds = {{
		title = locale(localeCarrier.locale, "embedWarning"),
		color = yellow,
		description = locale(localeCarrier.locale, msg, ...)
	}}, ephemeral = true}
end)

return warning