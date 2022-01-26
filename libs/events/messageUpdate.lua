local config = require "config"
local client = require "client"

local mercy = require "utils/mercy"

return function (message)	-- hearbeat check
	if message.author.id == client.user.id and message.channel.id == config.heartbeatChannel then
		mercy:reset()
		return
	end
end