local config = require "config"

local lobbies = require "storage/lobbies"

local warningEmbed = require "response/warning"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"

local commands = {
	lobby = require "commands/lobby",
	matchmaking = require "commands/matchmaking",
	companion = require "commands/companion",
	server = require "commands/server",
}

return function (interaction)
	local command, subcommand = interaction.option.name, interaction.option.option.name

	if command == "server" then
		if not interaction.guild then
			return "Command must be issued in guild", warningEmbed(interaction, "notInGuild")
		end

		if not (interaction.member:hasPermission("manageChannels") or config.owners[interaction.user.id]) then
			return "Bad user permissions", warningEmbed(interaction, "badUserPermissions")
		end

		return commands.server(interaction, subcommand)
	else
		local lobby = interaction.option.option.option.value
		if not lobbies[lobby.id] then return "Not a lobby", warningEmbed(interaction, "notLobby") end

		local ok, logMsg, embed = checkSetupPermissions(interaction, lobby)
		if not ok then
			return logMsg, embed
		end

		return commands[command](interaction, subcommand)
	end
end