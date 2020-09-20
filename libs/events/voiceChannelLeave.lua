local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local logger = require "discordia".storage.logger

return function (member, channel) -- now remove the unwanted corpses!
	if channel and channels[channel.id] then
		if #channel.connectedMembers == 0 then
			local mutex = lobbies[channels[channel.id].parent].mutex
			mutex:lock()
			channel:delete()
			logger:log(4, "GUILD %s: Deleted %s", channel.guild.id, channel.id)
			mutex:unlock()
		end
	end
end