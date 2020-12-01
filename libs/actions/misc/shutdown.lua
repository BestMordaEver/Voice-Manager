local discordia = require "discordia"
local client, clock, logger = discordia.storage.client, discordia.storage.clock, discordia.storage.logger
local config = require "config"

return function (message)
	if message then
		if message.author.id ~= config.ownerID then return end
		message:reply("Shutting down gracefully")
	end
	
	local status, msg = xpcall(function()
		client:setGame({name = "the maintenance", type = 3})
		clock:stop()
		client:stop()
	end, debug.traceback)
	logger:log(3, (status and "Shutdown successfull" or ("Couldn't shutdown gracefully, "..msg)))
	process:exit()
end