local client = require "client"
local logger = require "logger"

local channels = require "storage/channels"
local adjustHostPermissions = require "channelHandlers/adjustHostPermissions"

local permission = require "discordia".enums.permission

return function (channel, member)
	local channelData = channels[channel.id]
	local guild = channel.guild

	local companion = client:getChannel(channelData.companion)
	if companion then
		companion:getPermissionOverwriteFor(member):clearPermissions(permission.readMessages)
	end

	if channelData.host ~= member.user.id then return end

	local newHost = channel.connectedMembers:random()

	if not newHost then return end

	channelData:setHost(newHost.user.id)
	logger:log(4, "GUILD %s ROOM %s: migrating host from %s to %s", guild.id, channel.id, member.user.id, newHost.user.id)

	if channelData.parent then
		adjustHostPermissions(channel, newHost, member)
	end
end