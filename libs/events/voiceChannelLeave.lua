local client = require "client"
local logger = require "logger"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"
local enforceReservations = require "funcs/enforceReservations"

local permission = require "discordia".enums.permission

return function (member, channel) -- now remove the unwanted corpses!
	if channel and channels[channel.id] then
		if #channel.connectedMembers == 0 then
			if channels[channel.id].isPersistent then
				channels[channel.id]:delete()
				for _, permissionOverwrite in pairs(channel.permissionOverwrites) do
					if permissionOverwrite.type == "member" then permissionOverwrite:delete() end
				end
			else
				local parent = channels[channel.id].parent
				if parent then
					parent.mutex:lock()
					channel:delete()
					logger:log(4, "GUILD %s: Deleted %s", channel.guild.id, channel.id)
					parent.mutex:unlock()
				else
					channel:delete()
					logger:log(4, "GUILD %s: Deleted %s without sync, parent missing", channel.guild.id, channel.id)
				end
			end
		else
			enforceReservations(channel)
			
			local companion = client:getChannel(channels[channel.id].companion)
			if companion then
				companion:getPermissionOverwriteFor(member):denyPermissions(permission.readMessages)
			end
			
			if channels[channel.id].host == member.user.id then
				local newHost = channel.connectedMembers:random()
				
				if newHost then
					logger:log(4, "GUILD %s СHANNEL %s: Migrating host from %s to %s", channel.guild.id, channel.id, member.user.id, newHost.user.id)
					channels[channel.id]:updateHost(newHost.user.id)
					
					local lobby = client:getChannel(channels[channel.id].parent.id)
					if lobby then
						local perms = lobbies[lobby.id].permissions:toDiscordia()
						if #perms ~= 0 and lobby.guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then
							channel:getPermissionOverwriteFor(member):delete()
							channel:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
						end
					end
				end
			end
		end
	end
end