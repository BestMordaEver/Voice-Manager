local locale = require "locale"
local client = require "client"

local enums = require "discordia".enums
local componentType, inputStyle, interactionType = enums.componentType, enums.inputStyle, enums.interactionType

local lobbies = require "storage".lobbies

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local companionsInfoEmbed = require "embeds/companionsInfo"

local permissionCheck = require "funcs/permissionCheck"
local lobbyPreProcess = require "commands/lobbyPreProcess"

local greetingComponents = {
	{
		type = componentType.row,
		components = {
			{
				type = componentType.input,
				custom_id = "greeting",
				style = inputStyle.paragraph,
				label = locale.greetingModalTitle
			}
		}
	}
}

local subcommands
subcommands = {
	enable = function (interaction, channel)
		lobbies[channel.id]:setCompanionTarget(true)
		return "Lobby companion enabled", okEmbed(locale.companionEnable)
	end,

	disable = function (interaction, channel)
		lobbies[channel.id]:setCompanionTarget(nil)
		return "Lobby companion disabled", okEmbed(locale.companionDisable)
	end,

	category = function (interaction, channel, category)
		if not category then
			lobbies[channel.id]:setCompanionTarget(true)
			return "Companion target category reset", okEmbed(locale.categoryReset)
		end

		local isPermitted, logMsg, msg = permissionCheck(interaction, category)
		if isPermitted then
			lobbies[channel.id]:setCompanionTarget(category.id)
			return "Companion target category set", okEmbed(locale.categoryConfirm:format(category.name))
		end

		return logMsg, warningEmbed(msg)
	end,

	name = function (interaction, channel, name)
		if not name then name = "private-chat" end

		lobbies[channel.id]:setCompanionTemplate(name)
		return "Companion name template set", okEmbed(locale.nameConfirm:format(name))
	end,

	greeting = function (interaction, channel, greeting)
		if interaction.commandName == "reset" then greeting = "" end

		if greeting then
			if greeting == "" then
				lobbies[channel.id]:setGreeting(nil)
			else
				lobbies[channel.id]:setGreeting(greeting)
			end
			return "Companion greeting set", okEmbed(locale.greetingConfirm)
		end

		interaction:createModal("companion_greetingwidget_"..channel.id, locale.greetingModalTitle, greetingComponents)
		return "Sent greeting setup modal"
	end,

	greetingwidget = function (interaction, channel)
		return subcommands.greeting(interaction, channel, interaction.components[1].components[1].value)
	end,

	log = function (interaction, channel, logChannel)
		if logChannel then
			local isPermitted, logMsg, msg = permissionCheck(interaction, logChannel)
			if isPermitted then
				lobbies[channel.id]:setCompanionLog(logChannel.id)
				return "Companion log channel set", okEmbed(locale.logConfirm:format(logChannel.name))
			end

			return logMsg, warningEmbed(msg)
		end

		lobbies[channel.id]:setCompanionLog()
		return "Companion log channel reset", okEmbed(locale.logReset)
	end
}

return function (interaction, subcommand, argument)
	local channel, error = interaction.type == interactionType.modalSubmit and client:getChannel(argument) or lobbyPreProcess(interaction, companionsInfoEmbed)
	if error then return channel, error end
	return subcommands[subcommand](interaction, channel, argument)
end