local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"
local Overseer = require "overseer"

local okResponse = require "response/ok"
local warningResponse = require "response/warning"
local loggingInfoResponse = require "response/loggingInfo"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local lobbyPreProcess = require "channelUtils/lobbyPreProcess"

local offset = require "utils/offset"

local commands = {
	enable = function (interaction, lobby)
		local logChannel = interaction.options.channel.value
		local ok, logMsg, response = checkSetupPermissions(interaction, logChannel)
		if ok then
			lobbies[lobby.id]:setCompanionLog(logChannel.id)
			return "Logging enabled", okResponse(true, interaction.locale, "loggingEnableConfirm", logChannel.name)
		end

		return logMsg, response
	end,

	disable = function (interaction, lobby)
		local lobbyData = lobbies[lobby.id]
		for _, channelData in pairs(lobbyData.children) do
			if type(channelData) == "table" and channelData.id then
				Overseer.stop(channelData.id)
			end
		end
		lobbies[lobby.id]:setCompanionLog()
		return "Logging disabled", okResponse(true, interaction.locale, "loggingDisableConfirm")
	end,

	channel = function (interaction, lobby)
		local logChannel = interaction.options.channel.value
		local ok, logMsg, response = checkSetupPermissions(interaction, logChannel)
		if ok then
			lobbies[lobby.id]:setCompanionLog(logChannel.id)
			return "Logging channel set", okResponse(true, interaction.locale, "loggingChannelConfirm", logChannel.name)
		end

		return logMsg, response
	end,
}

return function (interaction, subcommand)
	-- UTC offset is a guild-wide setting, so it skips lobby resolution
	if subcommand == "offset" then
		local isPermitted, logMsg, response = checkSetupPermissions(interaction)
		if not isPermitted then return logMsg, response end

		local offsetMinutes = offset.parse(interaction.options.offset.value)
		if offsetMinutes == nil then
			return "Bad logging offset", warningResponse(true, interaction.locale, "loggingOffsetInvalid")
		end

		guilds[interaction.guild.id]:setLogTimeOffset(offsetMinutes)
		return "Logging offset set", okResponse(true, interaction.locale, "loggingOffsetConfirm", offset.format(offsetMinutes))
	end

	local channel, response = lobbyPreProcess(interaction, loggingInfoResponse)
	if response then return channel, response end

	return commands[subcommand](interaction, channel)
end
