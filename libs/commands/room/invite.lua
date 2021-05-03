local client = require "client"
local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"
local permission = require "discordia".enums.permission

return function (message, mentionString)
	local channel = message.member.voiceChannel
	local tryReservation = hostCheck(message) and hostPermissionCheck(message.member, channel, "moderate")
	
	mentionString = ""
	local invite = channel:createInvite()
	if invite then
		invite = "https://discord.gg/"..invite.code
		if #message.mentionedUsers == 0 then
			return "Created invite in room", "asIs", invite
		else
			for _,user in ipairs(message.mentionedUsers:toArray(function (user) return user ~= client.user end)) do
				if user:getPrivateChannel() then
					mentionString = mentionString .. user.mentionString .. " "
					user:getPrivateChannel():send(invite)
					if tryReservation then
						channel:getPermissionOverwriteFor(channel.guild:getMember(user)):allowPermissions(permission.connect, permission.speak)
					end
				end
			end
		end
	else
		return "Bot isn't permitted to create invites", "warning", locale.hostError
	end
	
	return "Sent invites to mentioned members", "ok", locale.inviteConfirm:format(mentionString)
end