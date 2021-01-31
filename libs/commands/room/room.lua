local locale = require "locale"
local channels = require "storage/channels"

local subcommands = {
	rename = require "commands/room/rename",
	resize = require "commands/room/resize",
	bitrate = require "commands/room/bitrate",
	blocklist = require "commands/room/blocklist",
	reservations = require "commands/room/reservations",
	kick = require "commands/room/kick",
	invite = require "commands/room/invite",
	mute = require "commands/room/mute",
	unmute = require "commands/room/unmute",
	host = require "commands/room/host",
	promote = require "commands/room/promote"
}

return function (message)
	local subcommand, argument = message.content:match("room%s*(%a*)%s*(.-)$")
	
	if not (message.member.voiceChannel and channels[message.member.voiceChannel.id]) then
		return "User not in room", "warning", locale.notInRoom
	end
	
	if subcommand == "" then
		return "Sent room info", "roomInfo", message.member.voiceChannel
	end
	
	if subcommands[subcommand] then
		return subcommands[subcommand](message, argument)
	else
		return "Bad room subcommand", "warning", locale.badSubcommand
	end
end