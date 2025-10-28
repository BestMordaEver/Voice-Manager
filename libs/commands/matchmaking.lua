local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local okResponse = require "response/ok"
local warningResponse = require "response/warning"
local matchmakingInfoResponse = require "response/matchmakingInfo"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local lobbyPreProcess = require "channelUtils/lobbyPreProcess"

local channelType = require "discordia".enums.channelType

local commands = {
	add = function (interaction, channel)
		if lobbies[channel.id] then
			return "Already registered", warningResponse(true, interaction.locale, "lobbyDupe")
		elseif channels[channel.id] and not channels[channel.id].isPersistent then
			return "Rooms can't be lobbies", warningResponse(true, interaction.locale, "channelDupe")
		end

		lobbies:store(channel):setMatchmaking(true)
		return "New matchmaking lobby added", okResponse(true, interaction.locale, "matchmakingAddConfirm", channel.name)
	end,

	remove = function (interaction, lobby)
		lobbies[lobby.id]:delete()
		return "Matchmaking lobby removed", okResponse(true, interaction.locale, "matchmakingRemoveConfirm", lobby.name)
	end,

	target = function (interaction, lobby)
		if interaction.commandName == "reset" then
			lobbies[lobby.id]:setTarget()
			return "Lobby target reset", okResponse(true, interaction.locale, "targetReset")
		end

		local target = interaction.options.target.value
		if target == lobby then
			lobbies[lobby.id]:setTarget()
			return "Lobby target reset", okResponse(true, interaction.locale, "targetReset")
		end

		if target.type == channelType.voice and not lobbies[target.id] then
			return "Selected target is not lobby or category", warningResponse(true, interaction.locale, "notLobby")
		end

		local ok, logMsg, response = checkSetupPermissions(interaction, target)
		if ok then
			lobbies[lobby.id]:setTarget(target.id)
			return "Lobby target set", okResponse(true, interaction.locale, "targetConfirm", target.name)
		end

		return logMsg, response
	end,

	mode = function (interaction, lobby)
		local mode = interaction.commandName == "reset" and "random" or interaction.options.mode.value

		lobbies[lobby.id]:setTemplate(mode)
		return "Matchmaking mode set", okResponse(true, interaction.locale, "modeConfirm", mode)
	end
}

return function (interaction, subcommand)
	local channel, response = lobbyPreProcess(interaction, matchmakingInfoResponse)
	if response then return channel, response end

	return commands[subcommand](interaction, channel)
end