local discordia = require "discordia"
local locale = require "locale"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local permission = discordia.enums.permission

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local permissions = bitfield(lobbies[channels[channel.id].parent].permissions)
	if not (message.guild:getMember(message.author)):hasPermission(channel, permission.manageChannels or permissions:has(permission.bits.name)) then
		message:reply(locale.badHostPermission)
		return "Insufficient permissions"
	end
	
	--channels:updateHost(channels)
	--return (#ids == 0 and "Successfully registered all" or ("Couldn't register "..table.concat(ids, " ")))
end