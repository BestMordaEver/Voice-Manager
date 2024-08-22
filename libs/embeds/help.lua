local locale = require "locale/runtime/localeHandler"
local embedHandler = require "handlers/embedHandler"
local buttons = require "handlers/componentHandler".helpButtons

local blurple = embedHandler.colors.blurple
local insert = table.insert

return embedHandler("help", function (interaction, page, ephemeral)

	local text = locale(interaction.locale, "help")[page]
	text.color = blurple
	insert(text.fields, {name = locale(interaction.locale, "helpLinksTitle"), value = locale(interaction.locale, "helpLinks")})

	return {embeds = {text}, components = buttons, ephemeral = ephemeral}
end)