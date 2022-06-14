local locale = require "locale"

local lobbies = require "storage".lobbies
local channels = require "storage".channels

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local matchmakingInfoEmbed = require "embeds/matchmakingInfo"

local permissionCheck = require "funcs/permissionCheck"
local lobbyPreProcess = require "commands/lobbyPreProcess"

local channelType = require "discordia".enums.channelType

local subcommands = {
	add = function (interaction, channel)
		if lobbies[channel.id] then
			return "Already registered", warningEmbed(locale.lobbyDupe)
		elseif channels[channel.id] and not channels[channel.id].isPersistent then
			return "Rooms can't be lobbies", warningEmbed(locale.channelDupe)
		end

		lobbies:store(channel):setMatchmaking(true)
		return "New matchmaking lobby added", okEmbed(locale.matchmakingAddConfirm:format(channel.name))
	end,

	remove = function (interaction, channel)
		if lobbies[channel.id] then
			lobbies[channel.id]:delete()
		end

		return "Matchmaking lobby removed", okEmbed(locale.matchmakingRemoveConfirm:format(channel.name))
	end,

	target = function (interaction, channel, target)
		if target and target ~= channel then
			if target.type == channelType.voice and not lobbies[target.id] then
				return "Selected target is not lobby or category", warningEmbed(locale.notLobby)
			end

			local isPermitted, logMsg, msg = permissionCheck(interaction, target)
			if isPermitted then
				lobbies[channel.id]:setTarget(target.id)
				return "Lobby target set", okEmbed(locale.targetConfirm:format(target.name))
			end

			return logMsg, warningEmbed(msg)
		end

		lobbies[channel.id]:setTarget()
		return "Lobby target reset", okEmbed(locale.targetReset)
	end,

	mode = function (interaction, channel, mode)
		if not mode then mode = "random" end

		lobbies[channel.id]:setTemplate(mode)
		return "Matchmaking mode set", okEmbed(locale.modeConfirm:format(mode))
	end
}

return function (interaction, subcommand, argument)
	local channel, embed = lobbyPreProcess(interaction, matchmakingInfoEmbed)
	if embed then return channel, embed end
	return subcommands[subcommand](interaction, channel, argument)
end