local client = require "client"
local channels = require "storage/channels"
local embeds = require "embeds/embeds"
local mercy = require "utils/mercy"
local status = require "funcs/status"
local config = require "config"

return function (date)
	channels:cleanup()
	embeds:tick()
	client:setGame(status())

	if config.heartbeat then
		-- hearbeat happens
		client:getChannel(config.heartbeatChannel):getMessage(config.heartbeatMessage):setContent(os.date())
		-- hearbeat is partial? stop it!
		if mercy:tick() or (config.dailyreboot and channels:people() == 0 and os.clock() > 86000) then mercy:kill() end
	end
end