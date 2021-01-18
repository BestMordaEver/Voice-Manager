local client = require "client"
local locale = require "locale"
local channels = require "storage/channels"

local subcommands = {
	rename = require "commands/room/rename",
	resize = require "commands/room/resize",
	bitrate = require "commands/room/bitrate",
	block = require "commands/room/block",
	reserve = require "commands/room/reserve",
	kick = require "commands/room/kick",
	invite = require "commands/room/invite",
	mute = require "commands/room/mute",
	unmute = require "commands/room/unmute",
	host = require "commands/room/host",
	promote = require "commands/room/promote"
}

return function (message)
	local subcommand, argument = message.content:match("room%s*(%a*)%s*(.-)$")
	
	local room = message.member.voiceChannel and channels[message.member.voiceChannel.id]
	if not room then
		message:reply(locale.notInRoom)
		return "User not in room"
	end
	
	if subcommand == "" then
		roomInfoEmbed(message)
		return "Sent room info"
	end
	
	if subcommands[subcommand] then
		return subcommands[subcommand](message, room, argument)
	else
		message:reply(locale.badSubcommand)
		return "Bad room subcommand"
	end
end