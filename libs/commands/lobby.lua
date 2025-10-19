local client = require "client"

local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local okResponse = require "response/ok"
local warningResponse = require "response/warning"
local lobbiesInfoResponse = require "response/lobbiesInfo"

local botPermissions = require "utils/botPermissions"
local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local lobbyPreProcess = require "commands/lobbyPreProcess"

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

	remove = function (interaction, channel)
		if lobbies[channel.id] then
			lobbies[channel.id]:delete()
		end

		return "Lobby removed", okResponse(true, interaction.locale, "removeConfirm", channel.name)
	end,

	category = function (interaction, channel, category)
		if category then
			local ok, logMsg, response = checkSetupPermissions(interaction, category)
			if ok then
				lobbies[channel.id]:setTarget(category.id)
				return "Lobby target category set", okResponse(true, interaction.locale, "categoryConfirm", category.name)
			end

			return logMsg, response
		end

		lobbies[channel.id]:setTarget()
		return "Lobby target category reset", okResponse(true, interaction.locale, "categoryReset")
	end,

	name = function (interaction, channel, name)
		if not name then name = "%nickname's% room" end
		lobbies[channel.id]:setTemplate(name)
		return "Lobby name template set", okResponse(true, interaction.locale, "nameConfirm", name)
	end,

	capacity = function (interaction, channel, capacity)
		if capacity then
			lobbies[channel.id]:setCapacity(capacity)
			return "Lobby capacity set", okResponse(true, interaction.locale, "capacityConfirm", capacity)
		end

		lobbies[channel.id]:setCapacity()
		return "Lobby capacity reset", okResponse(true, interaction.locale, "capacityReset")
	end,

	bitrate = function (interaction, channel, bitrate)
		if not bitrate then bitrate = 64 end
		local tier = channel.guild.premiumTier

		for _,feature in ipairs(interaction.guild.features) do
			if feature == "VIP_REGIONS" then tier = 3 end
		end

		if bitrate > tierRate[tier] then
			return "Bitrate OOB", warningResponse(true, interaction.locale, tierLocale[tier])
		end

		lobbies[channel.id]:setBitrate(bitrate*1000)
		return "Lobby bitrate set", okResponse(true, interaction.locale, "bitrateConfirm", bitrate)
	end,

	permissions = function (interaction, channel, perm)
		local lobbyData = lobbies[channel.id]

		if perm then
			local permissionBits = lobbyData.permissions
			for permissionName, permission in pairs(interaction.option.options) do
				if permissionBits.bits[permissionName] then
					-- metamethods resolve this as bit operations
					permissionBits.bitfield = permission.value and (permissionBits.bitfield + permissionBits.bits[permissionName]) or (permissionBits.bitfield - permissionBits.bits[permissionName])
				end
			end

			lobbyData:setPermissions(permissionBits)
			return "Lobby permissions set", okResponse(true, interaction.locale, "permissionsConfirm")
		end

		lobbyData:setPermissions(botPermissions())
		return "Lobby permissions reset", okResponse(true, interaction.locale, "permissionsReset")
	end,

	role = function (interaction, lobby, action)
		local lobbyData = lobbies[lobby.id]

		if action then
			action = action.name
			local role = interaction.option.option.options.role.value

			if action == "add" and not lobbyData.roles[role.id] then
				lobbyData:addRole(role.id)
			elseif action == "remove" and lobbyData.roles[role.id] then
				lobbyData:removeRole(role.id)
			end
		else
			lobbyData:removeRoles()
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

	limit = function (interaction, lobby, limit)
		if not limit then limit = 500 end

		lobbies[lobby.id]:setLimit(limit)
		return "Lobby limit set", okResponse(true, interaction.locale, "limitConfirm", limit)
	end,

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
	end,
}

return function (interaction, subcommand, argument)
	if subcommand == "view" then
		return "Sent lobby info", lobbiesInfoResponse(true, interaction.locale, argument or interaction.guild)
	end

	local channel, response = lobbyPreProcess(interaction)
	if response then return channel, response end

	return subcommands[subcommand](interaction, channel, argument)
end