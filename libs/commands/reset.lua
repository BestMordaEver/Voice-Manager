local locale = require "locale"
local config = require "config"

local lobbies = require "handlers/storageHandler".lobbies

local warningEmbed = require "embeds/warning"

local permissionCheck = require "handlers/channelHandler".checkPermissions

local commands = {
	lobby = require "commands/lobbies",
	matchmaking = require "commands/matchmaking",
	companion = require "commands/companions",
	server = require "commands/server",
}

return function (interaction)
	local command, subcommand = interaction.option.name, interaction.option.option.name

	if command == "server" then
		if not interaction.guild then
			return "Command must be issued in guild", locale.notInGuild
		end

		if not (interaction.member:hasPermission("manageChannels") or config.owners[interaction.user.id]) then
			return "Bad user permissions", warningEmbed(locale.badUserPermissions)
		end

		return commands.server(interaction, subcommand)
	else
		local lobby = interaction.option.option.option.value
		if not lobbies[lobby.id] then return "Not a lobby", warningEmbed(locale.notLobby) end

		local isPermitted, logMsg, userMsg = permissionCheck(interaction, lobby)
		if not isPermitted then
			return logMsg, warningEmbed(userMsg)
		end

		return commands[command](interaction, subcommand)
	end
end