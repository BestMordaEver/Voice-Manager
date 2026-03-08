local client = require "client"
local lobbies = require "storage/lobbies"

local interactionType = require "discordia".enums.interactionType

local warningResponse = require "response/warning"
local checkSetupPermissions = require "channelUtils/checkSetupPermissions"

return function (interaction, infoResponse)
	local lobby
	if interaction.type == interactionType.applicationCommand then
		lobby = interaction.options.lobby and interaction.options.lobby.value
	elseif interaction.type == interactionType.modalSubmit then
		lobby = client:getChannel(interaction.customId:match("%d+"))
	else
		lobby = client:getChannel(interaction.values[1])
	end

	if lobby and not lobbies[lobby.id] then
		return "Not a lobby", warningResponse(true, interaction.locale, "notLobby")
	end

	if interaction.subcommand == "view" or (interaction.customId and interaction.customId:match("view")) then
		return "Sent lobby info", infoResponse(true, interaction.locale,
		interaction.type == interactionType.applicationCommand and
			(interaction.option and interaction.option.value or interaction.guild)
		or
			client:getChannel(interaction.values[1]))
	end

	local channel = interaction.type == interactionType.applicationCommand and
		(interaction.options.lobby or interaction.options.channel).value
	or
		client:getChannel(interaction.customId:match("%d+")) or interaction.values and client:getChannel(interaction.values[1])

	local ok, logMsg, response = checkSetupPermissions(interaction, channel)
	if not ok then
		return logMsg, response
	end

	return channel
end