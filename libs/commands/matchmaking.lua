local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local okResponse = require "response/ok"
local warningResponse = require "response/warning"
local matchmakingInfoResponse = require "response/matchmakingInfo"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local lobbyPreProcess = require "commands/lobbyPreProcess"

local channelType = require "discordia".enums.channelType

local subcommands = {
	add = function (interaction, channel)
		if lobbies[channel.id] then
			return "Already registered", warningResponse(true, interaction.locale, "lobbyDupe")
		elseif channels[channel.id] and not channels[channel.id].isPersistent then
			return "Rooms can't be lobbies", warningResponse(true, interaction.locale, "channelDupe")
		end

		lobbies:store(channel):setMatchmaking(true)
		return "New matchmaking lobby added", okResponse(true, interaction.locale, "matchmakingAddConfirm", channel.name)
	end,

	remove = function (interaction, channel)
		if lobbies[channel.id] then
			lobbies[channel.id]:delete()
		end

		return "Matchmaking lobby removed", okResponse(true, interaction.locale, "matchmakingRemoveConfirm", channel.name)
	end,

	target = function (interaction, channel, target)
		if target and target ~= channel then
			if target.type == channelType.voice and not lobbies[target.id] then
				return "Selected target is not lobby or category", warningResponse(true, interaction.locale, "notLobby")
			end

			local ok, logMsg, response = checkSetupPermissions(interaction, target)
			if ok then
				lobbies[channel.id]:setTarget(target.id)
				return "Lobby target set", okResponse(true, interaction.locale, "targetConfirm", target.name)
			end

			return logMsg, response
		end

		lobbies[channel.id]:setTarget()
		return "Lobby target reset", okResponse(true, interaction.locale, "targetReset")
	end,

	mode = function (interaction, channel, mode)
		if not mode then mode = "random" end

		lobbies[channel.id]:setTemplate(mode)
		return "Matchmaking mode set", okResponse(true, interaction.locale, "modeConfirm", mode)
	end
}

return function (interaction, subcommand, argument)
	if subcommand == "view" then
		return "Sent lobby info", matchmakingInfoResponse(true, interaction.locale, argument or interaction.guild)
	end

	local channel, response = lobbyPreProcess(interaction)
	if response then return channel, response end

	return subcommands[subcommand](interaction, channel, argument)
end