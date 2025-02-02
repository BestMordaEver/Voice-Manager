local locale = require "locale/runtime/localeHandler"
local client = require "client"

local interactionType = require "discordia".enums.interactionType

local lobbies = require "storage/lobbies"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local companionsInfoEmbed = require "embeds/companionsInfo"

local checkSetupPermissions = require "channelHandlers/checkSetupPermissions"
local greetingComponents = require "utils/components".greetingComponents
local lobbyPreProcess = require "commands/lobbyPreProcess"

local subcommands
subcommands = {
	enable = function (interaction, channel)
		lobbies[channel.id]:setCompanionTarget(true)
		return "Lobby companion enabled", okEmbed(interaction, "companionEnable")
	end,

	disable = function (interaction, channel)
		lobbies[channel.id]:setCompanionTarget(nil)
		return "Lobby companion disabled", okEmbed(interaction, "companionDisable")
	end,

	category = function (interaction, channel, category)
		if not category then
			lobbies[channel.id]:setCompanionTarget(true)
			return "Companion target category reset", okEmbed(interaction, "categoryReset")
		end

		local isPermitted, logMsg, msg = checkSetupPermissions(interaction, category)
		if isPermitted then
			lobbies[channel.id]:setCompanionTarget(category.id)
			return "Companion target category set", okEmbed(interaction, "categoryConfirm", category.name)
		end

		return logMsg, warningEmbed(interaction, msg)
	end,

	name = function (interaction, channel, name)
		if not name then name = "private-chat" end

		lobbies[channel.id]:setCompanionTemplate(name)
		return "Companion name template set", okEmbed(interaction, "nameConfirm", name)
	end,

	greeting = function (interaction, channel, greeting)
		if interaction.commandName == "reset" then greeting = "" end

		if greeting then
			if greeting == "" then
				lobbies[channel.id]:setGreeting(nil)
			else
				lobbies[channel.id]:setGreeting(greeting)
			end
			return "Companion greeting set", okEmbed(interaction, "greetingConfirm")
		end

		interaction:createModal("companion_greetingwidget_"..channel.id, locale(interaction.locale, "greetingModalTitle"), greetingComponents(interaction))
		return "Sent greeting setup modal"
	end,

	greetingwidget = function (interaction, channel)	-- not exposed, access via modalInteraction
		return subcommands.greeting(interaction, channel, interaction.components[1].components[1].value)
	end,

	log = function (interaction, channel, logChannel)
		if logChannel then
			local isPermitted, logMsg, msg = checkSetupPermissions(interaction, logChannel)
			if isPermitted then
				lobbies[channel.id]:setCompanionLog(logChannel.id)
				return "Companion log channel set", okEmbed(interaction, "logConfirm", logChannel.name)
			end

			return logMsg, warningEmbed(interaction, msg)
		end

		lobbies[channel.id]:setCompanionLog()
		return "Companion log channel reset", okEmbed(interaction, "logReset")
	end
}

return function (interaction, subcommand, argument)
	local channel, embed
	if interaction.type == interactionType.modalSubmit then
		channel = client:getChannel(argument)
	else
		channel, embed = lobbyPreProcess(interaction, companionsInfoEmbed)
	end
	if embed then return channel, embed end
	return subcommands[subcommand](interaction, channel, argument)
end