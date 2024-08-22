local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local passwordButton = require "handlers/componentHandler".passwordInputButton
local blurple = embedHandler.colors.blurple

return embedHandler("password", function (interaction, channel)
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