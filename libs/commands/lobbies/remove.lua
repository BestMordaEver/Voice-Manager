local locale = require "locale"
local lobbies = require "storage/lobbies"
local okEmbed = require "embeds/ok"

return function (interaction, channel)
	if lobbies[channel.id] then
		lobbies[channel.id]:delete()
	end

	return "Lobby removed", okEmbed(locale.removeConfirm:format(channel.name))
end