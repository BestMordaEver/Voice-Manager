local locale = require "locale"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local member = message.guild:getMember(message.mentionedUsers.first)
	
	if not (member and member.voiceChannel and member.voiceChannel == channel) then
		message:reply(locale.noMember)
	end
	
	channels:updateHost(channel.id, member.user.id)
	message:reply(locale.newHost)
	return "New host assigned"
end