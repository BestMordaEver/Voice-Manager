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
	
	local silentRoom
	if guild.afkChannel then
		silentRoom = guild.afkChannel
	else
		silentRoom = channel.category:createVoiceChannel("Silent room")
		if not silentRoom then
			silentRoom = channel.guild:createVoiceChannel("Silent room")
		end
		if not silentRoom then silentRoom = nil end
	end
	
	mentionString = ""
	for _,user in ipairs(message.mentionedUsers:toArray(function (user) return user ~= client.user end)) do
		mentionString = mentionString .. user.mentionString .. " "
		local member = message.guild:getMember(user)
		channel:getPermissionOverwriteFor(member):denyPermissions(permission.speak)
		if member.voiceChannel == channel then
			member:setVoiceChannel(silentRoom)
			if silentRoom then member:setVoiceChannel(silentRoom) end
		end
	end
	
	if silentRoom then silentRoom:delete() end
	
	return "Muted mentioned members", "ok", locale.muteConfirm:format(mentionString)
end