local locale = require "locale"
local lobbies = require "storage/lobbies"
local okEmbed = require "embeds/ok"

return function (interaction, channel, reset)
	if reset then
		lobbies[channel.id]:setCapacity()
		return "Lobby capacity reset", okEmbed(locale.capacityReset)
	else
		local capacity = interaction.option.options.capacity.value
		lobbies[channel.id]:setCapacity(capacity)
		return "Lobby capacity set", okEmbed(locale.capacityConfirm:format(capacity))
	end
end