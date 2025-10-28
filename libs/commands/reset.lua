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
	return commands[interaction.subcommand](interaction, interaction.subcommandOption)
end