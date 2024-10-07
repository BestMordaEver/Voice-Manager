local config = require "config"

local lobbies = require "storage/lobbies"

local warningEmbed = require "embeds/warning"

local checkPermissions = require "handlers/channelHandler".checkPermissions

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

		local isPermitted, logMsg, userMsg = checkPermissions(interaction, lobby)
		if not isPermitted then
			return logMsg, warningEmbed(interaction, userMsg)
		end

		return commands[command](interaction, subcommand)
	end
end