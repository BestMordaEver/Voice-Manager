local config = require "config"
local client = require "client"

local channels = require "storage".channels

local mercy = require "utils/mercy"

local message

return function ()
    if config.heartbeat then
		-- hearbeat happens
        if not message then message = client:getChannel(config.heartbeatChannel):getMessage(config.heartbeatMessage) end
		message:setContent(os.date())
		-- hearbeat is partial? stop it!
		if mercy:tick() or (config.dailyreboot and channels:people() == 0 and os.clock() > 86000) then mercy:kill() end
	end
end