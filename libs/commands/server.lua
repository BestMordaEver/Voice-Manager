local client = require "client"

local guilds = require "storage/guilds"

local okResponse = require "response/ok"
local serverInfoResponse = require "response/serverInfo"

local botPermissions = require "utils/botPermissions"
local checkSetupPermissions = require "channelUtils/checkSetupPermissions"

local subcommands = {
	role = function (interaction, action)
		local guildData = guilds[interaction.guild.id]

		if action then
			action = action.name
			local role = interaction.option.option.option.value

			if action == "add" and not guildData.roles[role.id] then
				guildData:addRole(role.id)
			elseif action == "remove" and guildData.roles[role.id] then
				guildData:removeRole(role.id)
			end
		else
			guildData:removeRoles()
		end

		local roles = {}
		for roleID, _ in pairs(guildData.roles) do
			local role = client:getRole(roleID)
			if role then
				table.insert(roles, role.mentionString)
			else
				guildData:removeRole(roleID)
			end
		end

		if #roles == 0 then
			return "Changed managed server roles", okResponse(true, interaction.locale, "roleConfirmNoRoles")
		else
			return "Changed managed server roles", okResponse(true, interaction.locale, "roleConfirm", table.concat(roles," "))
		end
	end,

	limit = function (interaction, limit)
		if not limit then limit = 500 end

		guilds[interaction.guild.id]:setLimit(limit)
		return "Server limit set", okResponse(true, interaction.locale, "limitConfirm", limit)
	end,

	permissions = function (interaction, perm)
		local guildData = guilds[interaction.guild.id]

		if perm then
			local permissionBits = guildData.permissions

			for permissionName, permission in pairs(interaction.option.options) do
				if permissionBits.bits[permissionName] then
					permissionBits.bitfield = permission.value and (permissionBits.bitfield + permissionBits.bits[permissionName]) or (permissionBits.bitfield - permissionBits.bits[permissionName])
				end
			end

			guildData:setPermissions(permissionBits)
			return "Server permissions set", okResponse(true, interaction.locale, "permissionsConfirm")
		end

		guildData:setPermissions(botPermissions())
		return "Server permissions reset", okResponse(true, interaction.locale, "permissionsReset")
	end
}

return function (interaction, subcommand, argument)
	if subcommand == "view" then
		return "Sent server info", serverInfoResponse(true, interaction.locale, interaction.guild)
	end

	local isPermitted, logMsg, response = checkSetupPermissions(interaction)
	if not isPermitted then
		return logMsg, response
	end

	return subcommands[subcommand](interaction, argument)
end