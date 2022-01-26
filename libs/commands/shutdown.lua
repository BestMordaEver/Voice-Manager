local client = require "client"
local clock = require "clock"
local logger = require "logger"
local config = require "config"
local warningEmbed = require "embeds/warning"

return function (interaction)
	if interaction then
		if not config.owners[interaction.user.id] then return "Not owner", warningEmbed("You're not my father") end
		interaction:updateReply("Shutting down gracefully")
	end

	local status, msg = xpcall(function()
		client:setGame({name = "the maintenance", type = 3})
		clock:stop()
		client:stop()
	end, debug.traceback)
	logger:log(3, (status and "Shutdown successfull" or ("Couldn't shutdown gracefully, "..msg)))
	process:exit()
end