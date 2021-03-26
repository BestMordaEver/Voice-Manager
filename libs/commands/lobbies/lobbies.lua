local client = require "client"
local locale = require "locale"
local dialogue = require "utils/dialogue"
local permissionCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

local subcommands = {
	add = require "commands/lobbies/add",
	remove = require "commands/lobbies/remove",
	category = require "commands/lobbies/category",
	name = require "commands/lobbies/name",
	capacity = require "commands/lobbies/capacity",
	bitrate = require "commands/lobbies/bitrate",
	companion = require "commands/lobbies/companion",
	permissions = require "commands/lobbies/permissions",
	role = require "commands/lobbies/role"
}

return function (message)
	local subcommand, argument = message.content:match("lobbies%s*(%a*)%s*(.-)$")
	
	if subcommand == "" or argument == "" then
		return "Sent lobbies info", "lobbiesInfo", message.guild
	end
	
	local lobby
	if subcommand == "add" or subcommand == "remove" then
		lobby = client:getChannel(argument)
		if not (lobby and lobby.guild == message.guild) then
			argument = argument:lower()
			lobby = message.guild.voiceChannels:find(function(voiceChannel) return voiceChannel.name:lower() == argument end)
		end
		
		if not lobby then
			return "Couldn't find channel to add", "warning", locale.badChannel
		end
		
		dialogue(message.author.id, lobby.id)
	else
		lobby = client:getChannel(dialogue[message.author.id])
		if not lobby or lobby.type ~= channelType.voice then
			return "No lobby selected", "warning", locale.noLobbySelected
		end
	end
	
	local isPermitted, logMsg, userMsg = permissionCheck(message, lobby)
	if not isPermitted then
		return logMsg, "warning", userMsg
	end
	
	if subcommands[subcommand] then
		return subcommands[subcommand](message, lobby, argument)
	else
		return "Bad lobbies subcommand", "warning", locale.badSubcommand
	end
end