local discordia = require "discordia"
local channels = require "storage/channels"
local embeds = require "embeds"
local finalizer = require "finalizer"
local status = require "utils/status"

local client = discordia.storage.client

return function (date)
	-- hearbeat happens
	client:getChannel("676791988518912020"):getMessage("692117540838703114"):setContent(os.date())
	
	channels:cleanup()
	embeds:tick()
	client:setGame(status())
	
	-- hearbeat is partial? stop it!
	if finalizer:tick() 
	-- uncomment next line to allow bot to reboot daily
	-- or (channels:people() == 0 and os.clock() > 86000) 
	then finalizer:kill() end
end