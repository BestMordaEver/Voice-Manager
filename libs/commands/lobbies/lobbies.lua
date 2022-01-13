local permissionCheck = require "funcs/permissionCheck"
local warningEmbed = require "embeds/warning"
local lobbiesInfoEmbed = require "embeds/lobbiesInfo"

local subcommands = {
	add = require "commands/lobbies/add",
	remove = require "commands/lobbies/remove",
	category = require "commands/lobbies/category",
	name = require "commands/lobbies/name",
	capacity = require "commands/lobbies/capacity",
	bitrate = require "commands/lobbies/bitrate",
	permissions = require "commands/lobbies/permissions",
	role = require "commands/lobbies/role"
}

return function (interaction)
	local subcommand, options = interaction.option.name, interaction.option.options
	if subcommand == "view" then return "Sent lobby info", lobbiesInfoEmbed(interaction.guild, options and options.lobby.value) end
	local channel = (options.channel or options.lobby).value

	if subcommand == "add" or subcommand == "remove" or #options > 1 then
		local isPermitted, logMsg, userMsg = permissionCheck(interaction, channel)
		if not isPermitted then
			return logMsg, warningEmbed(userMsg)
		end
	end

	return subcommands[subcommand](interaction, channel)
end