local client = require "client"
local locale = require "locale"
local channels = require "storage/channels"

local subcommands = {
	rename = require "commands/chat/rename",
	hide = require "commands/chat/hide",
	show = require "commands/chat/show",
	mute = require "commands/chat/mute",
	unmute = require "commands/chat/unmute",
	clear = require "commands/chat/clear",
	--save = require "commands/chat/save"
}

return function (message)
	local subcommand, argument = message.content:match("chat%s*(%a*)%s*(.-)$")

	if not (message.member.voiceChannel and channels[message.member.voiceChannel.id]) then
		return "User not in room", "warning", locale.notInRoom
	end

	local chat = client:getChannel(channels[message.member.voiceChannel.id].companion)
	if not chat then
		return "Room doesn't have a chat", "warning", locale.noCompanion
	end

	if subcommand == "" then
		return "Sent chat info", "chatInfo", message.member.voiceChannel
	end

	if subcommands[subcommand] then
		return subcommands[subcommand](message, chat, argument)
	else
		return "Bad chat subcommand", "warning", locale.badSubcommand
	end
end