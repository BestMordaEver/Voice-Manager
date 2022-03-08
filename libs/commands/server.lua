local locale = require "locale"
local config = require "config"

local guilds = require "storage".guilds

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local serverInfoEmbed = require "embeds/serverInfo"

local botPermissions = require "utils/botPermissions"

local permission = require "discordia".enums.permission

local subcommands = {
	role = function (interaction, role)
		if not role then role = interaction.guild.defaultRole end

		guilds[interaction.guild.id]:setRole(role.id)
		return "Server managed role set", okEmbed(locale.roleConfirm)
	end,

	limit = function (interaction, limit)
		if not limit then limit = 500 end

		guilds[interaction.guild.id]:setLimit(limit)
		return "Server limit set", okEmbed(locale.limitConfirm)
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
			return "Server permissions set", okEmbed(locale.permissionsConfirm)
		end

		guildData:setPermissions(botPermissions())
		return "Server permissions reset", "ok", locale.permissionsReset
	end
}

return function (interaction, subcommand, argument)

	if not (interaction.member:hasPermission(permission.manageChannels) or config.owners[interaction.user.id]) then
		return "Bad user permissions", warningEmbed(locale.badUserPermissions)
	end

	if subcommand == "view" then
		return "Sent server info", serverInfoEmbed(interaction.guild)
	end

	return subcommands[subcommand](interaction, argument)
end