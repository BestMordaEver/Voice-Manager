local Timer = require "timer"
local logger = require "logger"
local channels = require "storage/channels"

return function (channel)
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