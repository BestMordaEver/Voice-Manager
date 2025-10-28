local client = require "client"

local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local okResponse = require "response/ok"
local warningResponse = require "response/warning"
local lobbiesInfoResponse = require "response/lobbiesInfo"
local regionResponse = require "response/region"

local botPermissions = require "utils/botPermissions"
local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local lobbyPreProcess = require "channelUtils/lobbyPreProcess"

local tierRate = {[0] = 96,128,256,384}
local tierLocale = {[0] = "bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}

local subcommands = {
	add = function (interaction, channel)
		if lobbies[channel.id] then
			return "Already registered", warningResponse(true, interaction.locale, "lobbyDupe")
		elseif channels[channel.id] and not channels[channel.id].isPersistent then
			return "Rooms can't be lobbies", warningResponse(true, interaction.locale, "channelDupe")
		end

		lobbies:store(channel)
		return "New lobby added", okResponse(true, interaction.locale, "addConfirm", channel.name)
	end,

	remove = function (interaction, lobby)
		lobbies[lobby.id]:delete()
		return "Lobby removed", okResponse(true, interaction.locale, "removeConfirm", lobby.name)
	end,

	category = function (interaction, lobby)
		if interaction.commandName == "reset" then
			lobbies[lobby.id]:setTarget()
			return "Lobby target category reset", okResponse(true, interaction.locale, "categoryReset")
		end

		local category = interaction.options.category.value
		local ok, logMsg, response = checkSetupPermissions(interaction, category)
		if ok then
			lobbies[lobby.id]:setTarget(category.id)
			return "Lobby target category set", okResponse(true, interaction.locale, "categoryConfirm", category.name)
		end
		return logMsg, response
	end,

	name = function (interaction, lobby)
		local name = interaction.commandName == "reset" and "%nickname's% room" or interaction.options.name.value
		lobbies[lobby.id]:setTemplate(name)
		return "Lobby name template set", okResponse(true, interaction.locale, "nameConfirm", name)
	end,

	capacity = function (interaction, lobby)
		if interaction.commandName == "reset" then
			lobbies[lobby.id]:setCapacity()
			return "Lobby capacity reset", okResponse(true, interaction.locale, "capacityReset")
		end

		local capacity = interaction.options.capacity.value
		lobbies[lobby.id]:setCapacity(capacity)
		return "Lobby capacity set", okResponse(true, interaction.locale, "capacityConfirm", capacity)
	end,

	bitrate = function (interaction, lobby)
		local bitrate = interaction.commandName == "reset" and 64 or interaction.options.bitrate.value
		local tier = lobby.guild.premiumTier

		for _,feature in ipairs(interaction.guild.features) do
			if feature == "VIP_REGIONS" then tier = 3 end
		end

		if bitrate > tierRate[tier] then
			return "Bitrate OOB", warningResponse(true, interaction.locale, tierLocale[tier])
		end

		lobbies[lobby.id]:setBitrate(bitrate*1000)
		return "Lobby bitrate set", okResponse(true, interaction.locale, "bitrateConfirm", bitrate)
	end,

	permissions = function (interaction, lobby)
		local lobbyData = lobbies[lobby.id]

		if interaction.commandName == "reset" then
			lobbyData:setPermissions(botPermissions())
			return "Lobby permissions reset", okResponse(true, interaction.locale, "permissionsReset")
		end

		local permissionBits = lobbyData.permissions
		for permissionName, permission in pairs(interaction.options) do
			if permissionBits.bits[permissionName] then
				-- metamethods resolve this as bit operations
				permissionBits.bitfield = permission.value and (permissionBits.bitfield + permissionBits.bits[permissionName]) or (permissionBits.bitfield - permissionBits.bits[permissionName])
			end
		end

		lobbyData:setPermissions(permissionBits)
		return "Lobby permissions set", okResponse(true, interaction.locale, "permissionsConfirm")
	end,

	role = function (interaction, lobby)
		local lobbyData = lobbies[lobby.id]

		if interaction.commandName == "reset" then
			lobbyData:removeRoles()
		else
			local role = interaction.options.role.value
			if interaction.subcommandOption == "add" and not lobbyData.roles[role.id] then
				lobbyData:addRole(role.id)
			elseif interaction.subcommandOption == "remove" and lobbyData.roles[role.id] then
				lobbyData:removeRole(role.id)
			end
		end

		local roles = {}
		for roleID, _ in pairs(lobbyData.roles) do
			local role = client:getRole(roleID)
			if role then
				table.insert(roles, role.mentionString)
			else
				lobbyData:removeRole(roleID)
			end
		end
		if #roles == 0 then
			return "Changed managed lobby roles", okResponse(true, interaction.locale, "roleConfirmNoRoles")
		else
			return "Changed managed lobby roles", okResponse(true, interaction.locale, "roleConfirm", table.concat(roles," "))
		end
	end,

	limit = function (interaction, lobby)
		local limit = interaction.command == "reset" and 500 or interaction.options.limit.value

		lobbies[lobby.id]:setLimit(limit)
		return "Lobby limit set", okResponse(true, interaction.locale, "limitConfirm", limit)
	end,

	region = function (interaction, lobby)
		if interaction.command == "reset" then
			lobbies[lobby.id]:setRegion(nil)
			return "Reset voice region", okResponse(true, interaction.locale, "regionReset")
		end

		if interaction.customId then
			local id, name = interaction.values[1]
			for _, region in pairs(interaction.guild:listVoiceRegions()) do
				if region.id == id then
					name = region.name
					break
				end
			end

			lobbies[lobby.id]:setRegion(id)
			return "Voice region set", okResponse(true, interaction.locale, "regionConfirm", name)
		end

		return "Sent voice region selector", regionResponse(true, interaction)
	end,

	--[[ TODO
	position = function (interaction, lobby)
		local order, type
		if interaction.name == "lobby" then
			order = interaction.option.options.order.value
			type = interaction.option.options.position.value
		else -- reset
			order = "desc"
			type = "bottom"
		end

		lobbies[lobby.id]:setPosition(order, type)
		return "Lobby target position set", okResponse(true, interaction.locale, "positionConfirm")
	end, --]]
}

return function (interaction, subcommand)
	local channel, response = lobbyPreProcess(interaction, lobbiesInfoResponse)
	if response then return channel, response end

	return subcommands[subcommand](interaction, channel)
end