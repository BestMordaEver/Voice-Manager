local locale = require "locale/runtime/localeHandler"
local embed = require "embeds/embed"

local passwordButton = require "utils/components".passwordInputButton
local blurple = embed.colors.blurple

return embed("password", function (interaction, channel)
	return {
		ephemeral = true,
		embeds = {
			{
				description = locale(interaction.locale, "passwordCheckText"),
				color = blurple,
				author = {
					name = channel.name,
					proxy_icon_url = channel.guild.iconURL
				}
			}
		},
		components = passwordButton(interaction)
	}
end)