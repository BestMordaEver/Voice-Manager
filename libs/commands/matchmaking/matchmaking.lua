local client = require "client"
local locale = require "locale"
local dialogue = require "utils/dialogue"
local matchmakingInfoEmbed = require "embeds/matchmakingInfo"
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
		matchmakingInfoEmbed(message)
		return "Sent matchmaking info"
	end
	
	if subcommand == "add" or subcommand == "remove" then
		local channel = client:getChannel(argument)
		if not (channel and channel.guild == message.guild) then
			argument = argument:lower()
			channel = message.guild.voiceChannels:find(function(voiceChannel) return voiceChannel.name == argument end)
		end
		
		if not channel then 
			message:reply(locale.badChannel)
			return "Couldn't find channel to add"
		end
		
		dialogue(message.author.id, channel.id)
	end

	local lobby = client:getChannel(dialogue[message.author.id])
	if not lobby or lobby.type ~= channelType.voice then
		message:reply(locale.noLobbySelected)
		return "No lobby selected"
	end
	
	if subcommands[subcommand] then
		return subcommands[subcommand](message, lobby, argument)
	else
		message:reply(locale.badSubcommand)
		return "Bad matchmaking subcommand"
	end
end