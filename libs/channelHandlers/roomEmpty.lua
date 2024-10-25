local timer = require "timer"
local logger = require "logger"
local channels = require "storage/channels"

local function reset (channel, mutex)
	logger:log(4, "GUILD %s LOBBY %s: delete timeout", channel.guild.id, channel.id)
	mutex:unlock()
end

return function (channel)
	local channelData = channels[channel.id]
	local parent = channelData and channelData.parent
	local guild = channel.guild

	if parent and parent.mutex then
		parent.mutex:lock()
		local timeout = timer.setTimeout(10000, reset, parent, parent.mutex)
		channel:delete()
		logger:log(4, "GUILD %s ROOM %s: deleted", guild.id, channel.id)
		timer.clearTimeout(timeout)
		parent.mutex:unlock()
	else
		channel:delete()
		logger:log(4, "GUILD %s ROOM %s: deleted without sync, parent missing", guild.id, channel.id)
	end
end