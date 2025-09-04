local enums = require "discordia".enums
local componentType = enums.componentType
local inputStyle = enums.inputStyle

local response = require "response/response"
local localeHandler = require "locale/runtime/localeHandler"

---@overload fun(locale : localeName) : table
local greetingSetup = response:newCustomType("greetingSetup", function (locale)
	return {
		type = componentType.label,
		label = localeHandler(locale, "greetingModalLabel"),
		components = {
			{
				type = componentType.textInput,
				custom_id = "greeting",
				style = inputStyle.paragraph,
			}
		}
	}
end, function (self, locale, channel)
	return "companion_greetingwidget_"..channel.id, localeHandler(locale, "greetingModalTitle"), {
		v2_components = true,
		components = self.factory(locale)
	}
end)

return greetingSetup