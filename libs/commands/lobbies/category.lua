local locale = require "locale"
local lobbies = require "storage/lobbies"
local permissionCheck = require "funcs/permissionCheck"
local channelType = require "discordia".enums.channelType
local warningEmbed = require "embeds/warning"
local okEmbed = require "embeds/ok"

return function (interaction, channel, reset)
	if reset then
		lobbies[channel.id]:setTarget()
		return "Lobby target category reset", okEmbed(locale.categoryReset)
	else
		local category = interaction.option.options.category.value
		if not category or category.type ~= channelType.category then
			return "Couldn't find target category", warningEmbed(locale.badCategory)
		end

		local isPermitted, logMsg, msg = permissionCheck(interaction, category)
		if isPermitted then
			lobbies[channel.id]:setTarget(category.id)
			return "Lobby target category set", okEmbed(locale.categoryConfirm:format(category.name))
		else
			return logMsg, warningEmbed(msg)
		end
	end
end