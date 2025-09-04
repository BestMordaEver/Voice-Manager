local enums = require "discordia".enums
local componentType = enums.componentType
local buttonStyle = enums.buttonStyle
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

local pages = {[0] = "helpContents", "helpLobby", "helpMatchmaking", "helpCompanion", "helpRoom", "helpServer", "helpOther"}

local translatedHelp = {}

for localeName, locale in pairs(localeHandler) do
	
end

---@overload fun(ephemeral : boolean, locale : localeName, page : integer) : table
local help = response("help", response.colors.blurple, function (locale, page)
	page = page or 0
	return {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, pages[page])
		},
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "helpLinks")
		},
		{
			type = componentType.row,
			components = {
				{
					type = componentType.button,
					label = "Lobbies",
					custom_id = "help_1",
					style = buttonStyle.primary,
					disabled = page == 1
				},{
					type = componentType.button,
					label = "Matchmaking",
					custom_id = "help_2",
					style = buttonStyle.primary,
					disabled = page == 2
				},{
					type = componentType.button,
					label = "Companion",
					custom_id = "help_3",
					style = buttonStyle.primary,
					disabled = page == 3
				}
			}
		},
		{
			type = componentType.row,
			components = {
				{
					type = componentType.button,
					label = "Room",
					custom_id = "help_4",
					style = buttonStyle.primary,
					disabled = page == 4
				},{
					type = componentType.button,
					label = "Server",
					custom_id = "help_5",
					style = buttonStyle.primary,
					disabled = page == 5
				},{
					type = componentType.button,
					label = "Other",
					custom_id = "help_6",
					style = buttonStyle.primary,
					disabled = page == 6
				}
			}
		}
	}
end)

return help