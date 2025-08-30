local locale = require "locale/runtime/localeHandler"
local embed = require "response/embed"
local buttons = require "utils/components".helpButtons

local blurple = embed.colors.blurple
local insert, copy = table.insert, table.deepcopy

return embed("help", function (interaction, page, ephemeral)

	local embed = copy(locale(interaction.locale, "help")[page])
	embed.color = blurple
	insert(embed.fields, {name = locale(interaction.locale, "helpLinksTitle"), value = locale(interaction.locale, "helpLinks")})

	return {embeds = {embed}, components = buttons, ephemeral = ephemeral}
end)