local locale = require "locale/runtime/localeHandler"
local embedHandler = require "handlers/embedHandler"
local buttons = require "handlers/componentHandler".helpButtons

local blurple = embedHandler.colors.blurple
local insert, copy = table.insert, table.deepcopy

return embedHandler("help", function (interaction, page, ephemeral)

	local embed = copy(locale(interaction.locale, "help")[page])
	embed.color = blurple
	insert(embed.fields, {name = locale(interaction.locale, "helpLinksTitle"), value = locale(interaction.locale, "helpLinks")})

	return {embeds = {embed}, components = buttons, ephemeral = ephemeral}
end)