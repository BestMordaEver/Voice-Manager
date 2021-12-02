local client = require "client"
local clock = require "clock"
local logger = require "logger"
local config = require "config"

return function (message)
	if message then
		if not config.owners[message.author.id] then return "Not owner", "warning", "You're not my father" end
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