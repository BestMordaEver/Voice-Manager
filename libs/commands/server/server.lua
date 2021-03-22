local locale = require "locale"
local config = require "config"
local permission = require "discordia".enums.permission

local subcommands = {
	role = require "commands/server/role",
	limit = require "commands/server/limit",
	permissions = require "commands/server/permissions",
	prefix = require "commands/server/prefix"
}

return function (message)
	if not (message.member:hasPermission(channel, permission.manageChannels) or config.owners[message.author.id]) then
		return "Bad user permissions", "warning", locale.badUserPermissions
	end

	local subcommand, argument = message.content:match("server%s*(%a*)%s*(.-)$")
	
	if subcommand == "" or argument == "" then
		return "Sent server info", "serverInfo", message.guild
	end
	
	if subcommands[subcommand] then
		return subcommands[subcommand](message, argument)
	else
		return "Bad server subcommand", "warning", locale.badSubcommand
	end
end