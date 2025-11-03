local enums = require "discordia".enums
local componentType = enums.componentType
local inputStyle = enums.inputStyle

local response = require "response/response"
local localeHandler = require "locale/localeHandler"

---@overload fun(locale : localeName, channel : GuildVoiceChannel) : table
local greetingSetup = response:newCustomType("greetingSetup",
function (locale)
	return {{
		type = componentType.label,
		label = localeHandler(locale, "greetingModalLabel"),
		component = {
			type = componentType.textInput,
			custom_id = "greeting",
			style = inputStyle.paragraph,
		}
	}}
end,
function (self, locale, channel)
	return "companion_greeting_"..channel.id, localeHandler(locale, "greetingModalTitle"), self.factory(locale)
end)

return greetingSetup