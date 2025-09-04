local localeHandler = require "locale/runtime/localeHandler"
local client = require "client"

local interactionType = require "discordia".enums.interactionType

local lobbies = require "storage/lobbies"

local okResponse = require "response/ok"
local greetingSetupResponse = require "response/greetingSetup"
local companionsInfoResponse = require "response/companionsInfo"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local greetingComponents = require "utils/components".greetingComponents
local lobbyPreProcess = require "commands/lobbyPreProcess"

local subcommands
subcommands = {
	enable = function (interaction, channel)
		lobbies[channel.id]:setCompanionTarget(true)
		return "Lobby companion enabled", okResponse(true, interaction.locale, "companionEnable")
	end,

	disable = function (interaction, channel)
		lobbies[channel.id]:setCompanionTarget(nil)
		return "Lobby companion disabled", okResponse(true, interaction.locale, "companionDisable")
	end,

	category = function (interaction, channel, category)
		if not category then
			lobbies[channel.id]:setCompanionTarget(true)
			return "Companion target category reset", okResponse(true, interaction.locale, "categoryReset")
		end

		local ok, logMsg, response = checkSetupPermissions(interaction, category)
		if ok then
			lobbies[channel.id]:setCompanionTarget(category.id)
			return "Companion target category set", okResponse(true, interaction.locale, "categoryConfirm", category.name)
		end

		return logMsg, response
	end,

	name = function (interaction, channel, name)
		if not name then name = "private-chat" end

		lobbies[channel.id]:setCompanionTemplate(name)
		return "Companion name template set", okResponse(true, interaction.locale, "nameConfirm", name)
	end,

	greeting = function (interaction, channel, greeting)
		if interaction.commandName == "reset" then greeting = "" end

		if greeting then
			if greeting == "" then
				lobbies[channel.id]:setGreeting(nil)
			else
				lobbies[channel.id]:setGreeting(greeting)
			end
			return "Companion greeting set", okResponse(true, interaction.locale, "greetingConfirm")
		end

		interaction:createModal(greetingSetupResponse(interaction.locale))
		return "Sent greeting setup modal"
	end,

	greetingwidget = function (interaction, channel)	-- not exposed, access via modalInteraction
		return subcommands.greeting(interaction, channel, interaction.components[1].components[1].value)
	end,

	log = function (interaction, channel, logChannel)
		if logChannel then
			local ok, logMsg, response = checkSetupPermissions(interaction, logChannel)
			if ok then
				lobbies[channel.id]:setCompanionLog(logChannel.id)
				return "Companion log channel set", okResponse(true, interaction.locale, "logConfirm", logChannel.name)
			end

			return logMsg, response
		end

		lobbies[channel.id]:setCompanionLog()
		return "Companion log channel reset", okResponse(true, interaction.locale, "logReset")
	end
}

return function (interaction, subcommand, argument)
	local channel, response
	if interaction.type == interactionType.modalSubmit then
		channel = client:getChannel(argument)
	else
		channel, response = lobbyPreProcess(interaction, companionsInfoResponse)
	end
	if response then return channel, response end
	return subcommands[subcommand](interaction, channel, argument)
end