local client = require "client"
local locale = require "locale"
local dialogue = require "utils/dialogue"
local permissionCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

local subcommands = {
	category = require "commands/companions/category",
	name = require "commands/companions/name"
}

return function (message)
	local subcommand, argument = message.content:match("companions%s*(%a*)%s*(.-)$")
	
	if subcommand == "" or argument == "" then
		return "Sent companions info", "companionsInfo", message.guild
	end

	local lobby = client:getChannel(dialogue[message.author.id])
	if not lobby or lobby.type ~= channelType.voice then
		return "No lobby selected", "warning", locale.noLobbySelected
	end
	
	local isPermitted, logMsg, userMsg = permissionCheck(message, lobby)
	if not isPermitted then
		return logMsg, "warning", userMsg
	end
	
	if subcommands[subcommand] then
		return subcommands[subcommand](message, lobby, argument)
	else
		return "Bad companions subcommand", "warning", locale.badSubcommand
	end
end