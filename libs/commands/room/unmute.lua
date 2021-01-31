local client = require "client"
local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"
local permission = require "discordia".enums.permission

return function (message, mentionString)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end
	
	local isPermitted = hostPermissionCheck(message.member, channel, "mute")
	if not isPermitted then
		return "Insufficient permissions", "warning", locale.badHostPermission
	end
	
	mentionString = ""
	for _,user in ipairs(message.mentionedUsers:toArray(function (user) return user ~= client.user end)) do
		mentionString = mentionString .. user.mentionString .. " "
		channel:getPermissionOverwriteFor(message.guild:getMember(user)):clearPermissions(permission.speak)
	end
	
	return "Unmuted mentioned members", "ok", locale.unmuteConfirm:format(mentionString)
end