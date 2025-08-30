local lobbies = require "storage/lobbies"

local warningEmbed = require "embeds/warning"
local checkSetupPermissions = require "channelUtils/checkSetupPermissions"

return function (interaction, embed)
	local subcommand, options = interaction.option.name, interaction.option.options
	if subcommand == "view" then return "Sent lobby info", embed(interaction, options and options.lobby.value) end
	local channel = (options.lobby or options.channel or interaction.option.option.options.lobby).value

	local ok, logMsg, embed = checkSetupPermissions(interaction, channel)
	if not ok then
		return logMsg, embed
	end

	if not (subcommand == "add" or lobbies[channel.id]) then
		return "Not a lobby", warningEmbed(interaction, "notLobby")
	end

	return channel
end