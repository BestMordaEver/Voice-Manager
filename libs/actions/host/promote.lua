local discordia = require "discordia"
local locale = require "locale"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local client = discordia.storage.client
local permission = discordia.enums.permission

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local oldHost = message.guild:getMember(message.author)
	local member = message.guild:getMember(message.mentionedUsers.first)
	
	if not (member and member.voiceChannel and member.voiceChannel == channel) then
		message:reply(locale.noMember)
		return
	end
	
	local channelData = channels[channel.id]
	channelData:updateHost(member.user.id)
	local lobby = client:getChannel(channelData.parent.id)
	if lobby then
		local perms = bitfield(channelData.parent.permissions):toDiscordia()
		if #perms ~= 0 and lobby.guild.me:getPermissions(lobby):has(permission.manageRoles, table.unpack(perms)) then
			channel:getPermissionOverwriteFor(oldHost):delete()
			channel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
		end
	end

	message:reply(locale.newHost)
	return "New host assigned"
end