local client = require "client"

local guilds = require "storage/guilds"

local okResponse = require "response/ok"
local serverInfoResponse = require "response/serverInfo"

local botPermissions = require "utils/botPermissions"
local checkSetupPermissions = require "channelUtils/checkSetupPermissions"

local subcommands = {
	role = function (interaction)
		local guildData = guilds[interaction.guild.id]

		if interaction.commandName == "reset" then
			guildData:removeRoles()
		else
			local role = interaction.option.value
			if interaction.subcommandOption == "add" and not guildData.roles[role.id] then
				guildData:addRole(role.id)
			elseif interaction.subcommandOption == "remove" and guildData.roles[role.id] then
				guildData:removeRole(role.id)
			end
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

	limit = function (interaction)
		local limit = interaction.commandName == "reset" and 500 or interaction.option.value

		guilds[interaction.guild.id]:setLimit(limit)
		return "Server limit set", okResponse(true, interaction.locale, "limitConfirm", limit)
	end,

	permissions = function (interaction)
		local guildData = guilds[interaction.guild.id]

		if interaction.commandName == "reset" then
			guildData:setPermissions(botPermissions())
			return "Server permissions reset", okResponse(true, interaction.locale, "permissionsReset")
		end

		local permissionBits = guildData.permissions

		for permissionName, permission in pairs(interaction.options) do
			if permissionBits.bits[permissionName] then
				permissionBits.bitfield = permission.value and (permissionBits.bitfield + permissionBits.bits[permissionName]) or (permissionBits.bitfield - permissionBits.bits[permissionName])
			end
		end

		guildData:setPermissions(permissionBits)
		return "Server permissions set", okResponse(true, interaction.locale, "permissionsConfirm")
	end
}

return function (interaction, subcommand)
	if subcommand == "view" then
		return "Sent server info", serverInfoResponse(true, interaction.locale, interaction.guild)
	end

	local isPermitted, logMsg, response = checkSetupPermissions(interaction)
	if not isPermitted then
		return logMsg, response
	end

	return subcommands[subcommand](interaction)
end