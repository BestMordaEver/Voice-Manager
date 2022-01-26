local locale = require "locale"
local config = require "config"
local lobbies = require "storage/lobbies"
local warningEmbed = require "embeds/warning"

local permissionCheck = require "funcs/permissionCheck"

local commands = {
	lobbies = require "commands/lobbies",
	matchmaking = require "commands/matchmaking",
	companions = require "commands/companions",
	server = require "commands/server",
}

return function (interaction)
	local command, subcommand = interaction.option.name, interaction.option.option.name

	if command == "server" then
		if not (interaction.member:hasPermission("manageChannels") or config.owners[interaction.user.id]) then
			return "Bad user permissions", warningEmbed(locale.badUserPermissions)
		end
		return commands.server(interaction)
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