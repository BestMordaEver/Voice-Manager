local locale = require "locale"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local warningEmbed = require "embeds/warning"
local okEmbed = require "embeds/ok"

return function (interaction, channel)
	if lobbies[channel.id] then
		return "Already registered", warningEmbed(locale.lobbyDupe)
	elseif channels[channel.id] and not channels[channel.id].isPersistent then
		return "Rooms can't be lobbies", warningEmbed(locale.channelDupe)
	end
	lobbies(channel.id)
	return "New lobby added", okEmbed(locale.addConfirm:format(channel.name))
end