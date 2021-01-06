local locale = require "locale"
local commandHelpEmbed = require "embeds/commandHelp"
local serverInfoEmbed = require "embeds/serverInfo"
local permission = require "discordia".enums.permission

local subcommands = {
	role = require "commands/server/role",
	limit = require "commands/server/limit",
	permissions = require "commands/server/permissions",
	prefix = require "commands/server/prefix"
}

return function (message)
	if not message.member:hasPermission(permission.manageChannels) then
		message:reply(locale.badPermissions)
		return "Bad user permissions"
	end
	
	local subcommand, argument = message.content:match("server%s*(%a*)%s*(.-)$")
	
	if subcommand == "" then
		serverInfoEmbed(message)
		return "Sent server info"
	end
	
	
	if subcommands[subcommand] then
		if argument == "" then
			commandHelpEmbed(message, "server"..subcommand)
			return "Sent server "..subcommand.." help"
		else
			return subcommands[subcommand](message, argument)
		end
	else
		message:reply(locale.badSubcommand)
		return "Bad server subcommand"
	end
end