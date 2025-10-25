local enums = require "discordia".enums
local interactionType = enums.interactionType
local commandType = enums.applicationCommandType
local commandsNamespace = require "namespaces/commands"

local function invite ()
	return "Sent support invite", {content = "https://discord.gg/tqj6jvT"}
end

local undeferrable = {view = true, greeting = true, widget = true, passwordinit = true, row = true, key = true, nuke = true}

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
	if interaction.type == interactionType.applicationCommand then
		if interaction.commandType == commandType.chatInput then
			if not undeferrable[interaction.subcommand] then interaction:deferReply(true) end
			return self[interaction.commandName](interaction, interaction.subcommand)
		elseif interaction.commandType == commandType.user then
			if interaction.commandName == commandsNamespace.Invite then
				return self[commandsNamespace.room](interaction, "invite", interaction.target)
			end
		elseif interaction.commandType == commandType.message then

		end
	elseif interaction.type == interactionType.messageComponent then
		local command = interaction.customId:match("^[^_]+")
		local argument = interaction.customId:match("_([^_]+)")
		if not undeferrable[argument] then interaction:deferReply(true) end
		return self[command](interaction, argument)
	end
end})