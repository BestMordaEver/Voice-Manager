local client = require "client"
local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"

return function (message, mentionString)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end
	
	local isPermitted = hostPermissionCheck(message.member, channel, "moderate")
	if not isPermitted then
		return "Insufficient permissions", "warning", locale.badHostPermission
	end
	
	mentionString = ""
	for _,user in ipairs(message.mentionedUsers:toArray(function (user) return user ~= client.user end)) do
		mentionString = mentionString .. user.mentionString .. " "
		message.guild:getMember(user):setVoiceChannel()
	end
	
	return "Kicked mentioned members", "ok", locale.kickConfirm:format(mentionString)
end