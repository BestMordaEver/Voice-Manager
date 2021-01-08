local client = require "client"
local locale = require "locale"
local dialogue = require "utils/dialogue"
local lobbiesInfoEmbed = require "embeds/lobbiesInfo"
local channelType = require "discordia".enums.channelType

local subcommands = {
	add = require "commands/lobbies/add",
	remove = require "commands/lobbies/remove",
	category = require "commands/lobbies/category",
	name = require "commands/lobbies/name",
	capacity = require "commands/lobbies/capacity",
	companion = require "commands/lobbies/companion",
	permissions = require "commands/lobbies/permissions",
}

return function (message)
	local subcommand, argument = message.content:match("lobbies%s*(%a*)%s*(.-)$")
	
	if subcommand == "" or argument == "" then
		lobbiesInfoEmbed(message)
		return "Sent lobbies info"
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
		return "Bad lobbies subcommand"
	end
end