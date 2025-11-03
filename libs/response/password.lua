local enums = require "discordia".enums
local componentType = enums.componentType
local buttonStyle = enums.buttonStyle
local localeHandler = require "locale/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, channel : GuildVoiceChannel) : table
local password = response("password", response.colors.blurple, function (locale, channel)
	return {
		{
			type = componentType.textDisplay,
			content = channel.name
		},
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "passwordCheckText")
		},
		{
			type = componentType.row,
			components = {
				{
					type = componentType.button,
					style = buttonStyle.primary,
					label = localeHandler(locale, "passwordEnter"),
					custom_id = "room_passwordinit",
				}
			}
		}
	}
end)

return password