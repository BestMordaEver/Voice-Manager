local config = require "config"

local lobbies = require "storage/lobbies"

local warningResponse = require "response/warning"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"

local commands = {
	lobby = require "commands/lobby",
	matchmaking = require "commands/matchmaking",
	companion = require "commands/companion",
	server = require "commands/server",
}

return function (interaction)
	local command, subcommand = interaction.subcommand, interaction.subcommandOption

	if command == "server" then
		if not interaction.guild then
			return "Command must be issued in guild", warningResponse(true, interaction.locale, "notInGuild")
		end

		if not (interaction.member:hasPermission("manageChannels") or config.owners[interaction.user.id]) then
			return "Bad user permissions", warningResponse(true, interaction.locale, "badUserPermissions")
		end

		return commands.server(interaction, subcommand)
	else
		local lobby = interaction.options.lobby.value
		if not lobbies[lobby.id] then return "Not a lobby", warningResponse(true, interaction.locale, "notLobby") end

		local ok, logMsg, response = checkSetupPermissions(interaction, lobby)
		if not ok then
			return logMsg, response
		end

		return commands[command][subcommand](interaction, lobby)
	end
end