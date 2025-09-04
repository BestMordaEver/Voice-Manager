local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName) : table
local error = response("error", response.colors.red, function (locale)
	local errorReactions = locale(locale, "errorReaction")

	return {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "embedError")
		},
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "error", errorReactions[math.random(1, #errorReactions)])
		}
	}
end)

return error