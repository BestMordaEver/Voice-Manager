local locale = require "locale"

local lobbies = require "storage/lobbies"

local warningEmbed = require "embeds/warning"
local checkPermissions = require "handlers/channelHandler".checkPermissions

local soloArged = {add = true, remove = true, enable = true, disable = true}

return function (interaction, embed)
	local subcommand, options = interaction.option.name, interaction.option.options
	if subcommand == "view" then return "Sent lobby info", embed(interaction, options and options.lobby.value) end
	local channel = (options.lobby or options.channel or interaction.option.option.options.lobby).value

	if soloArged[subcommand] or #options > 1 then
		local isPermitted, logMsg, userMsg = checkPermissions(interaction, channel)
		if not isPermitted then
			return logMsg, warningEmbed(userMsg)
		end
	end

	if not (subcommand == "add" or lobbies[channel.id]) then
		return "Not a lobby", warningEmbed(interaction, "notLobby")
	end

	return channel
end