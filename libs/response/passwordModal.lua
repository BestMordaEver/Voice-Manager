local enums = require "discordia".enums
local componentType = enums.componentType
local inputStyle = enums.inputStyle

local response = require "response/response"
local localeHandler = require "locale/localeHandler"

---@overload fun(locale : localeName, channel : GuildVoiceChannel) : table
local passwordModal = response:newCustomType("passwordModal",
function (locale)
	return {{
		type = componentType.label,
		label = localeHandler(locale, "password"),
		component = {
			type = componentType.textInput,
			custom_id = "password",
			style = inputStyle.short,
		}
	}}
end,
function (self, locale, channel)
	return "room_passwordcheck", localeHandler(locale, "passwordEnter"), self.factory(locale)
end)

return passwordModal