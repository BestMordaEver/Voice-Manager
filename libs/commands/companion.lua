local interactionType = require "discordia".enums.interactionType

local lobbies = require "storage/lobbies"

local okResponse = require "response/ok"
local greetingSetupResponse = require "response/greetingSetup"
local companionsInfoResponse = require "response/companionsInfo"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local lobbyPreProcess = require "channelUtils/lobbyPreProcess"

return setmetatable({
	enable = function (interaction, lobby)
		lobbies[lobby.id]:setCompanionTarget(true)
		return "Lobby companion enabled", okResponse(true, interaction.locale, "companionEnable")
	end,

	disable = function (interaction, lobby)
		lobbies[lobby.id]:setCompanionTarget(nil)
		return "Lobby companion disabled", okResponse(true, interaction.locale, "companionDisable")
	end,

	category = function (interaction, lobby)
		if interaction.commandName == "reset" then
			lobbies[lobby.id]:setCompanionTarget(true)
			return "Companion target category reset", okResponse(true, interaction.locale, "categoryReset")
		end

		local category = interaction.options.category.value
		local ok, logMsg, response = checkSetupPermissions(interaction, category)
		if ok then
			lobbies[lobby.id]:setCompanionTarget(category.id)
			return "Companion target category set", okResponse(true, interaction.locale, "categoryConfirm", category.name)
		end

		return logMsg, response
	end,

	name = function (interaction, lobby)
		local name = interaction.commandName == "reset" and "private-chat" or interaction.options.name.value

		lobbies[lobby.id]:setCompanionTemplate(name)
		return "Companion name template set", okResponse(true, interaction.locale, "nameConfirm", name)
	end,

	greeting = function (interaction, lobby)
		local greeting
		if interaction.commandName == "reset" then
			greeting = ""
		elseif interaction.options and interaction.options.greeting then
			greeting = interaction.options.greeting.value
		elseif interaction.type == interactionType.modalSubmit then
			greeting = interaction.components[1].component.value
		end

		if greeting then
			if greeting == "" then
				lobbies[lobby.id]:setGreeting(nil)
			else
				lobbies[lobby.id]:setGreeting(greeting)
			end
			return "Companion greeting set", okResponse(true, interaction.locale, "greetingConfirm")
		end
p(greetingSetupResponse(interaction.locale, lobby))
		local ok, msg = interaction:createModal(greetingSetupResponse(interaction.locale, lobby))
		if ok then
			return "Sent greeting setup modal"
		else
			error(msg)
		end
	end,

	log = function (interaction, lobby)
		if interaction.commandName == "reset" then
			lobbies[lobby.id]:setCompanionLog()
			return "Companion log channel reset", okResponse(true, interaction.locale, "logReset")
		end

		local logChannel = interaction.options.channel.value
		local ok, logMsg, response = checkSetupPermissions(interaction, logChannel)
		if ok then
			lobbies[lobby.id]:setCompanionLog(logChannel.id)
			return "Companion log channel set", okResponse(true, interaction.locale, "logConfirm", logChannel.name)
		end

		return logMsg, response
	end
},{__call = function (self, interaction, subcommand)
	local channel, response = lobbyPreProcess(interaction, companionsInfoResponse)
	if response then return channel, response end

	return self[subcommand](interaction, channel)
end})