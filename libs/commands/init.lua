local function invite ()
	return "Sent support invite", "https://discord.gg/tqj6jvT"
end

-- all possible bot commands are processed in corresponding files, should return message for logger
return setmetatable({
	help = require "commands/help",
	reset = require "commands/reset",
	server = require "commands/server",
	lobby = require "commands/lobbies",
	companion = require "commands/companions",
	matchmaking = require "commands/matchmaking",
	room = require "commands/room",
	chat = require "commands/chat",
	create = require "commands/create",
	delete = require "commands/delete",
	shutdown = require "commands/shutdown",
	support = invite,
	invite = invite,
	exec = require "commands/exec"
},{__call = function (self, interaction)
	local command, subcommand, argument = interaction.commandName, interaction.option and interaction.option.name
	if interaction.option and interaction.option.options then
		for optionName, option in pairs(interaction.option.options) do
			if optionName ~= "lobby" then argument = option end
		end
	end
	return self[command](interaction, subcommand, argument and (argument.value or argument))
end})