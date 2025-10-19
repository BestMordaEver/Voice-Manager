local commandType = require "discordia".enums.applicationCommandType
local commandsNamespace = require "namespaces/commands"

local function invite ()
	return "Sent support invite", {content = "https://discord.gg/tqj6jvT"}
end

local undeferrable = {greeting = true}

-- all possible bot commands are processed in corresponding files, should return message for logger
return setmetatable({
	[commandsNamespace.help] = require "commands/help",
	[commandsNamespace.reset] = require "commands/reset",
	[commandsNamespace.server] = require "commands/server",
	[commandsNamespace.lobby] = require "commands/lobby",
	[commandsNamespace.companion] = require "commands/companion",
	[commandsNamespace.matchmaking] = require "commands/matchmaking",
	[commandsNamespace.room] = require "commands/room",
	[commandsNamespace.clone] = require "commands/clone",
	[commandsNamespace.delete] = require "commands/delete",
	[commandsNamespace.users] = require "commands/users",
	[commandsNamespace.ping] = require "commands/ping",
	[commandsNamespace.shutdown] = require "commands/shutdown",
	[commandsNamespace.support] = invite,
	[commandsNamespace.invite] = invite,
	[commandsNamespace.exec] = require "commands/exec"
},{__call = function (self, interaction)
	if interaction.commandType == commandType.chatInput then
		-- /lobby add channelname or /room lock or any other command

		local command, subcommand, argument = interaction.commandName, interaction.option and not interaction.option.value and interaction.option.name
		-- for /lobby add channelname, command is lobby, subcommand is add
		-- for /help lobby, command is help, subcommand is nil, since lobby is a name-value pair of article-lobby, which is resolved later as an argument
		-- for /room rename voice newname, command is room, subcommand is rename, argument is nil. Both "voice" and new name are resolved by command script later

		if not undeferrable[subcommand] then interaction:deferReply(true) end
		-- undeferrable commands that might need to send a modal

		-- resolving the argument here
		if interaction.option then
			if interaction.option.option then
				argument = interaction.option.option
			elseif interaction.option.options then
				for optionName, option in pairs(interaction.option.options) do
					if optionName ~= "lobby" then argument = option end
					break
				end
			end
		end
		-- the argument can be used as indication of work to be done, and actual arguments will be resolved by the command function itself
		-- like /lobby permissions ...

		-- most commands will treat argument nil as a call for reset
		return self[command](interaction, subcommand, argument and (argument.value or argument))
	elseif interaction.type == commandType.user then
		if interaction.commandName == commandsNamespace.Invite then
			return self[commandsNamespace.room](interaction, "invite", interaction.target)
		end
	elseif interaction.type == commandType.message then

	end
end})