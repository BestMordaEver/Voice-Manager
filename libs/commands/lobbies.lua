local locale = require "locale"

local lobbies = require "storage".lobbies
local channels = require "storage".channels

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local lobbiesInfoEmbed = require "embeds/lobbiesInfo"

local botPermissions = require "utils/botPermissions"
local permissionCheck = require "funcs/permissionCheck"
local lobbyPreProcess = require "commands/lobbyPreProcess"

local tierRate = {[0] = 96,128,256,384}
local tierLocale = {[0] = "bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}


local subcommands = {
	add = function (interaction, channel)
		if lobbies[channel.id] then
			return "Already registered", warningEmbed(locale.lobbyDupe)
		elseif channels[channel.id] and not channels[channel.id].isPersistent then
			return "Rooms can't be lobbies", warningEmbed(locale.channelDupe)
		end

		lobbies:store(channel)
		return "New lobby added", okEmbed(locale.addConfirm:format(channel.name))
	end,

	remove = function (interaction, channel)
		if lobbies[channel.id] then
			lobbies[channel.id]:delete()
		end

		return "Lobby removed", okEmbed(locale.removeConfirm:format(channel.name))
	end,

	category = function (interaction, channel, category)
		if category then
			local isPermitted, logMsg, msg = permissionCheck(interaction, category)
			if isPermitted then
				lobbies[channel.id]:setTarget(category.id)
				return "Lobby target category set", okEmbed(locale.categoryConfirm:format(category.name))
			end

			return logMsg, warningEmbed(msg)
		end

		lobbies[channel.id]:setTarget()
		return "Lobby target category reset", okEmbed(locale.categoryReset)
	end,

	name = function (interaction, channel, name)
		if not name then name = "%nickname's% room" end
		lobbies[channel.id]:setTemplate(name)
		return "Lobby name template set", okEmbed(locale.nameConfirm:format(name))
	end,

	capacity = function (interaction, channel, capacity)
		if capacity then
			lobbies[channel.id]:setCapacity(capacity)
			return "Lobby capacity set", okEmbed(locale.capacityConfirm:format(capacity))
		end

		lobbies[channel.id]:setCapacity()
		return "Lobby capacity reset", okEmbed(locale.capacityReset)
	end,

	bitrate = function (interaction, channel, bitrate)
		if not bitrate then bitrate = 64 end
		local tier = interaction.guild.premiumTier

		for _,feature in ipairs(interaction.guild.features) do
			if feature == "VIP_REGIONS" then tier = 3 end
		end

		if bitrate > tierRate[tier] then
			return "Bitrate OOB", warningEmbed(locale[tierLocale[tier]])
		end

		lobbies[channel.id]:setBitrate(bitrate*1000)
		return "Lobby bitrate set", okEmbed(locale.bitrateConfirm:format(bitrate))
	end,

	permissions = function (interaction, channel, perm)
		local lobbyData = lobbies[channel.id]

		if perm then
			local permissionBits = lobbyData.permissions
			for permissionName, permission in pairs(interaction.option.options) do
				if permissionBits.bits[permissionName] then
					permissionBits.bitfield = permission.value and (permissionBits.bitfield + permissionBits.bits[permissionName]) or (permissionBits.bitfield - permissionBits.bits[permissionName])
				end
			end

			lobbyData:setPermissions(permissionBits)
			return "Lobby permissions set", okEmbed(locale.permissionsConfirm)
		end

		lobbyData:setPermissions(botPermissions())
		return "Lobby permissions reset", okEmbed(locale.permissionsReset)
	end,

	role = function (interaction, lobby, role)
		if role then
			lobbies[lobby.id]:setRole(interaction.option.options.role.value.id)
		else
			lobbies[lobby.id]:setRole(interaction.guild.defaultRole.id)
		end
		return "Lobby managed role set", okEmbed(locale.roleConfirm)
	end
}

return function (interaction, subcommand, argument)
	local channel, embed = lobbyPreProcess(interaction, lobbiesInfoEmbed)
	if embed then return channel, embed end
	return subcommands[subcommand](interaction, channel, argument)
end