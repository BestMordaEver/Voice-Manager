local client = require "client"
local locale = require "locale"
local lobbies = require "storage/lobbies"
local dialogue = require "utils/dialogue"
local permissionCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

local subcommands = {
	add = require "commands/matchmaking/add",
	remove = require "commands/matchmaking/remove",
	target = require "commands/matchmaking/target",
	mode = require "commands/matchmaking/mode"
}

return function (message)
	local subcommand, argument = message.content:match("matchmaking%s*(%a*)%s*(.-)$")
	
	if subcommand == "" or argument == "" then
		return "Sent matchmaking info", "matchmakingInfo", message.guild
	end
	
	if subcommand == "add" or subcommand == "remove" then
		local channel = client:getChannel(argument)
		if not (channel and channel.guild == message.guild) then
			argument = argument:lower()
			channel = message.guild.voiceChannels:find(function(voiceChannel) return voiceChannel.name:lower() == argument end)
		end
		
		if not channel then 
			return "Couldn't find channel to add", "warning", locale.badChannel
		end
		
		if subcommand == "add" then dialogue(message.author.id, channel.id) end
	end

	local lobby = client:getChannel(dialogue[message.author.id])
	if not (lobby and lobbies[lobby.id] and lobby.type == channelType.voice) then
		return "No lobby selected", "warning", locale.noLobbySelected
	end
	
	local isPermitted, logMsg, userMsg = permissionCheck(message, lobby)
	if not isPermitted then
		return logMsg, "warning", userMsg
	end
	
	if subcommands[subcommand] then
		return subcommands[subcommand](message, lobby, argument)
	else
		return "Bad matchmaking subcommand", "warning", locale.badSubcommand
	end
end