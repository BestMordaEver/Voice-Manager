local lobbies = require "storage/lobbies"

local warningResponse = require "response/warning"
local checkSetupPermissions = require "channelUtils/checkSetupPermissions"

return function (interaction, response)
	local subcommand, options = interaction.option.name, interaction.option.options
	if subcommand == "view" then return "Sent lobby info", response(interaction.locale, options and options.lobby.value) end
	local channel = (options.lobby or options.channel or interaction.option.option.options.lobby).value

	local ok, logMsg, response = checkSetupPermissions(interaction, channel)
	if not ok then
		return logMsg, response
	end

	if not (subcommand == "add" or lobbies[channel.id]) then
		return "Not a lobby", warningResponse(true, interaction.locale, "notLobby")
	end

	return channel
end