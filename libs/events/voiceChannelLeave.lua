local discordia = require "discordia"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"

local client = discordia.storage.client
local logger = discordia.storage.logger
local permission = discordia.enums.permission

return function (member, channel) -- now remove the unwanted corpses!
	if channel and channels[channel.id] then
		if #channel.connectedMembers == 0 then
			local mutex = lobbies[channels[channel.id].parent].mutex
			mutex:lock()
			channel:delete()
			logger:log(4, "GUILD %s: Deleted %s", channel.guild.id, channel.id)
			mutex:unlock()
		elseif channels[channel.id].host == member.user.id then
			local newHost = channel.connectedMembers:random()
			
			if newHost then
				channels:updateHost(channel.id, newHost.user.id)
				
				local lobby = client:getChannel(channels[channel.id].parent)
				if lobby then
					local perms = bitfield(lobbies[lobby.id].permissions):toDiscordia()
					if #perms ~= 0 and lobby.guild.me:getPermissions(lobby):has(permission.manageRoles, table.unpack(perms)) then
						channel:getPermissionOverwriteFor(member):delete()
						channel:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
					end
				end
			end
		end
	end
end