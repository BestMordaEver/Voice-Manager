local client = require "client"
local logger = require "logger"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"

local permission = require "discordia".enums.permission

return function (member, channel) -- now remove the unwanted corpses!
	if channel and channels[channel.id] then
		if #channel.connectedMembers == 0 then
			local lobbyData = channels[channel.id].parent
			if lobbyData then
				lobbyData.mutex:lock()
				channel:delete()
				logger:log(4, "GUILD %s: Deleted %s", channel.guild.id, channel.id)
				lobbyData.mutex:unlock()
			else
				channel:delete()
				logger:log(4, "GUILD %s: Deleted %s without sync, parent missing", channel.guild.id, channel.id)
			end
		else
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
						if #perms ~= 0 and lobby.guild.me:getPermissions(lobby):has(permission.manageRoles, table.unpack(perms)) then
							channel:getPermissionOverwriteFor(member):delete()
							channel:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
						end
					end
				end
			end
		end
	end
end