local client = require "client"
local logger = require "logger"
local channels = require "storage/channels"
local embeds = require "embeds/embeds"
local mercy = require "utils/mercy"
local status = require "utils/status"
local config = require "config"

return function (date)
	channels:cleanup()
	embeds:tick()
	client:setGame(status())
	
	if config.hearbeat then
		-- hearbeat happens
		client:getChannel(config.hearbeatChannel):getMessage(config.hearbeatMessage):setContent(os.date())
		-- hearbeat is partial? stop it!
		if mercy:tick() 
		-- uncomment next line to allow bot to reboot daily
		-- or (channels:people() == 0 and os.clock() > 86000) 
		then mercy:kill() end
	end
end