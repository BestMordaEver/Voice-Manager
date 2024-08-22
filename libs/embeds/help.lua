local locale = require "locale"
local embedHandler = require "handlers/embedHandler"
local buttons = require "handlers/componentHandler".helpButtons

local blurple = embedHandler.colors.blurple
local insert = table.insert

return embedHandler("help", function (interaction, page, ephemeral)
	local helps = {}

	for name, text in pairs(locale(interaction.locale, "help")) do
		text.color = blurple
		insert(text.fields, {name = locale(interaction.locale, "helpLinksTitle"), value = locale(interaction.locale, "helpLinks")})
		helps[name] = text
	end

	return {embeds = {helps[page]}, components = buttons, ephemeral = ephemeral}
end)