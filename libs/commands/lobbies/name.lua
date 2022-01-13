local locale = require "locale"
local lobbies = require "storage/lobbies"
local okEmbed = require "embeds/ok"

return function (interaction, channel, reset)
	local name = reset and "%nickname's% room" or interaction.option.options.name.value
	lobbies[channel.id]:setTemplate(name)
	return "Lobby name template set", okEmbed(locale.nameConfirm:format(name))
end