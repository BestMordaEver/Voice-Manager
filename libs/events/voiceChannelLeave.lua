local client = require "client"
local logger = require "logger"

local guilds = require "storage".guilds
local lobbies = require "storage".lobbies
local channels = require "storage".channels

local enforceReservations = require "funcs/enforceReservations"

local permission = require "discordia".enums.permission

return function (member, channel) -- now remove the unwanted corpses!
	local channelData = channel and channels[channel.id]
	if channelData then
		if #channel.connectedMembers == 0 then
			if channelData.parentType == 0 then
				local parent = channelData.parent
				if parent and parent.mutex then
					parent.mutex:lock()
					channel:delete()
					logger:log(4, "GUILD %s ROOM %s: deleted", channel.guild.id, channel.id)
					parent.mutex:unlock()
				else
					channel:delete()
					logger:log(4, "GUILD %s ROOM %s: deleted without sync, parent missing", channel.guild.id, channel.id)
				end
			elseif channelData.parentType == 3 then
				if channelData.parent then
					local parent = client:getChannel(channelData.parent.id)
					if parent then
						local overwrite = parent:getPermissionOverwriteFor(member)
						if not (overwrite:getAllowedPermissions():has(permission.connect) or overwrite:getDeniedPermissions():has(permission.sendMessages)) then
							overwrite:clearPermissions(permission.connect)
						end
					end
					channel:delete()
					logger:log(4, "GUILD %s ROOM %s: finished password flow", channel.guild.id, channel.id)
				end
			else
				channelData:delete()
				local perms = guilds[channel.guild.id].permissions:toDiscordia()
				if #perms ~= 0 and channel.guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then
					for _, permissionOverwrite in pairs(channel.permissionOverwrites) do
						if permissionOverwrite.type == "member" then permissionOverwrite:delete() end
					end
				end
				logger:log(4, "GUILD %s CHANNEL %s: reset", channel.guild.id, channel.id)
			end
		else
			enforceReservations(channel)

			if not channelData then return end
			local companion = client:getChannel(channelData.companion)
			if companion then
				companion:getPermissionOverwriteFor(member):clearPermissions(permission.readMessages)
			end

			if channelData.host == member.user.id then
				local newHost = channel.connectedMembers:random()

				if newHost then
					logger:log(4, "GUILD %s ROOM %s: migrating host from %s to %s", channel.guild.id, channel.id, member.user.id, newHost.user.id)
					channelData:setHost(newHost.user.id)

					if channelData.parent and client:getChannel(channelData.parent.id) then
						local perms = lobbies[channelData.parent.id].permissions:toDiscordia()
						if #perms ~= 0 and client:getChannel(channelData.parent.id).guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then
							channel:getPermissionOverwriteFor(member):delete()
							channel:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
						end
					end
				end
			end
		end
	end
end