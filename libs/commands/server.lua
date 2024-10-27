local client = require "client"

local guilds = require "storage/guilds"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local serverInfoEmbed = require "embeds/serverInfo"

local botPermissions = require "utils/botPermissions"
local checkSetupPermissions = require "channelHandlers/checkSetupPermissions"

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
			return "Changed managed server roles", okEmbed(interaction, "roleConfirmNoRoles")
		else
			return "Changed managed server roles", okEmbed(interaction, "roleConfirm", table.concat(roles," "))
		end
	end,

	limit = function (interaction, limit)
		if not limit then limit = 500 end

		guilds[interaction.guild.id]:setLimit(limit)
		return "Server limit set", okEmbed(interaction, "limitConfirm", limit)
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
			return "Server permissions set", okEmbed(interaction, "permissionsConfirm")
		end

		guildData:setPermissions(botPermissions())
		return "Server permissions reset", okEmbed(interaction, "permissionsReset")
	end
}

return function (interaction, subcommand, argument)
	if subcommand == "view" then
		return "Sent server info", serverInfoEmbed(interaction)
	end

	local isPermitted, logMsg, userMsg = checkSetupPermissions(interaction)
	if not isPermitted then
		return logMsg, warningEmbed(interaction, userMsg)
	end

	return subcommands[subcommand](interaction, argument)
end