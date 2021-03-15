local locale = require "locale"
local client = require "client"
local dialogue = require "utils/dialogue"
local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"

local permissionCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType

local commands = {
	lobbies = {
		bitrate = require "commands/lobbies/bitrate",
		capacity = require "commands/lobbies/capacity",
		category = require "commands/lobbies/category",
		companion = require "commands/lobbies/companion",
		name = require "commands/lobbies/name",
		permissions = require "commands/lobbies/permissions"
	},
	
	matchmaking = {
		mode = require "commands/matchmaking/mode",
		target = require "commands/matchmaking/target"
	},
	
	companions = {
		category = require "commands/companions/category",
		greeting = require "commands/companions/greeting",
		name = require "commands/companions/name"
	},
	
	server = {
		limit = require "commands/server/limit",
		permissions = require "commands/server/permissions",
		prefix = require "commands/server/prefix",
		role = require "commands/server/role"
	}
}

return function (message)
	local command, subcommand = message.content:match("reset%s*(%a+)%s*(%a+)")
	if not commands[command] or not commands[command][subcommand] then
		return "Bad subcommand", "warning", locale.badSubcommand
	end
	
	local lobbyData, guildData = lobbies[dialogue[message.author.id]], guilds[message.guild.id]
	
	if command == "server" then
		if not message.member:hasPermission(permission.manageChannels) then
			return "Bad user permissions", "warning", locale.badUserPermissions
		end
		return commands.server[subcommand](message)
	else
		local lobby = client:getChannel(dialogue[message.author.id])
		if not lobby or lobby.type ~= channelType.voice then
			return "No lobby selected", "warning", locale.noLobbySelected
		end
		
		local isPermitted, logMsg, userMsg = permissionCheck(message, lobby)
		if not isPermitted then
			return logMsg, "warning", userMsg
		end
		
		return subcommands[subcommand](message, lobby)
	end
end