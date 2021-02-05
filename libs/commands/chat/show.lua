local client = require "client"
local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"
local enforceReservations = require "funcs/enforceReservations"
local permission = require "discordia".enums.permission

return function (message, chat)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end
	
	local isPermitted = hostPermissionCheck(message.member, channel, "moderate")
	if not isPermitted then
		return "Insufficient permissions", "warning", locale.badHostPermission
	end
	
	local mentionString = ""
	
	for _,user in ipairs(message.mentionedUsers:toArray(function (user) return user ~= client.user end)) do
		mentionString = mentionString .. user.mentionString .. " "
		chat:getPermissionOverwriteFor(chat.guild:getMember(user)):allowPermissions(permission.readMessages)
	end
	return "Made the chat visible to mentioned members", "ok", locale.showConfirm:format(mentionString)
end