local locale = require "locale"

local lobbies = require "storage/lobbies"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local companionsInfoEmbed = require "embeds/companionsInfo"

local permissionCheck = require "funcs/permissionCheck"
local lobbyPreProcess = require "funcs/lobbyPreProcess"

local subcommands = {
	enable = function (interaction, channel, enable)
		lobbies[channel.id]:setCompanionTarget(enable or nil)
		return enable and "Lobby companion enable" or "Lobby companion disabled", "ok", locale.companionToggle:format(enable and "enable" or "disable")
	end,

	category = function (interaction, channel, category)
		if not category then
			lobbies[channel.id]:setCompanionTarget()
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
		return "Companion name template set", "ok", locale.nameConfirm:format(name)
	end,

	greeting = function (interaction, channel, greeting)
		if greeting then
			lobbies[channel.id]:setGreeting(interaction.option.options.greeting.value)
			return "Companion greeting set", okEmbed(locale.greetingConfirm)
		end

		lobbies[channel.id]:setGreeting()
		return "Companion greeting reset", okEmbed(locale.greetingReset)
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

return function (interaction)
	local command, channel = lobbyPreProcess(interaction, companionsInfoEmbed)
	if subcommands[command] then return subcommands[command](interaction, channel) end
	return command, channel
end