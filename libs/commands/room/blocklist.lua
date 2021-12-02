local client = require "client"
local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"
local permission = require "discordia".enums.permission

return function (message, argument)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end

	local isPermitted = hostPermissionCheck(message.member, channel, "moderate")
	if not isPermitted then
		return "Insufficient permissions", "warning", locale.badHostPermission
	end

	local subcommand = argument:match("%a+")
	local mentionString = ""

	if subcommand == "add" then
		for _,user in ipairs(message.mentionedUsers:toArray(function (user) return user ~= client.user end)) do
			mentionString = mentionString .. user.mentionString .. " "
			channel:getPermissionOverwriteFor(channel.guild:getMember(user)):denyPermissions(permission.connect)
		end
		return "Blocked mentioned members", "ok", locale.blockConfirm:format(mentionString)
	elseif subcommand == "remove" then
		for _,user in ipairs(message.mentionedUsers:toArray(function (user) return user ~= client.user end)) do
			mentionString = mentionString .. user.mentionString .. " "
			channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect)
		end
		return "Unlocked mentioned members", "ok", locale.unblockConfirm:format(mentionString)
	elseif subcommand == "clear" then
		for _, permissionOverwrite in ipairs(channel.permissionOverwrites:toArray(function (permissionOverwrite) return permissionOverwrite.type == "member" end)) do
			mentionString = mentionString .. permissionOverwrite:getObject().user.mentionString .. " "
			permissionOverwrite:clearPermissions(permission.connect)
		end
		return "Cleared blocklist", "ok", locale.unblockConfirm:format(mentionString)
	else
		return "No subcommand", "warning", locale.badSubcommand
	end
end