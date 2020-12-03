local discordia = require "discordia"
local channels = require "storage/channels"
local embeds = require "utils/embeds"
local mercy = require "utils/mercy"
local status = require "utils/status"
local config = require "config"

local client = discordia.storage.client

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