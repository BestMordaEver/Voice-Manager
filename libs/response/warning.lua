local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, text : textLine, ... : string) : table
local warning = response("warning", response.colors.yellow, function (locale, msg, ...)
	return {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "embedWarning")
		},
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, msg, ...)
		}
	}
end)

return warning