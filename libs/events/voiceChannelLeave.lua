local Timer = require "timer"
local client = require "client"
local logger = require "logger"

local channels = require "storage/channels"

local adjustHostPermissions = require "channelUtils/adjustHostPermissions"

local enums = require "discordia".enums
local permission = enums.permission
local overwriteType = enums.overwriteType



local function roomEmpty (channel)
	local channelData = channels[channel.id]
	local parent = channelData and channelData.parent
	local guild = channel.guild

	if parent and parent.mutex then
		parent.mutex:lock()
		local timer = parent.mutex:unlockAfter(10000)
		channel:delete()
		logger:log(4, "GUILD %s ROOM %s: deleted", guild.id, channel.id)
		parent.mutex:unlock()
		Timer.clearTimeout(timer)
	else
		channel:delete()
		logger:log(4, "GUILD %s ROOM %s: deleted without sync, parent missing", guild.id, channel.id)
	end
end



local function passwordCompleted (channel, member)
	local channelData = channels[channel.id]
	local guild = channel.guild

	if channelData.parent then
		local parent = client:getChannel(channelData.parent.id)
		if parent then
			local overwrite = parent:getPermissionOverwriteFor(member)
			if not (overwrite:getAllowedPermissions():has(permission.connect) or overwrite:getDeniedPermissions():has(permission.sendMessages)) then
				overwrite:clearPermissions(permission.connect)
			end
		end
		channel:delete()
		logger:log(4, "GUILD %s ROOM %s: finished password flow", guild.id, channel.id)
	end
end



local function roomReset (channel)
	local channelData = channels[channel.id]
	local guild = channel.guild

	channelData:delete()

	if not channelData.parent then return end

	local perms = channelData.parent.permissions:toDiscordia()
	if #perms == 0 or not guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then return end

	for _, permissionOverwrite in pairs(channel.permissionOverwrites) do
		if permissionOverwrite.type == overwriteType.member then permissionOverwrite:delete() end
	end

	logger:log(4, "GUILD %s CHANNEL %s: reset", guild.id, channel.id)
end



local function memberLeft (channel, member)
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



return function (member, channel) -- now remove the unwanted corpses!
	local channelData = channel and channels[channel.id]
	if channelData then
		if #channel.connectedMembers == 0 then
			if channelData.parentType == 0 then
				roomEmpty(channel)
			elseif channelData.parentType == 3 then
				passwordCompleted(channel, member)
			else
				roomReset(channel)
			end
		else
			memberLeft(channel, member)
		end
	end
end