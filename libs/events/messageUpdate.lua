local mercy = require "utils/mercy"
local config = require "config"
local client = require "client"

return function (message)	-- hearbeat check
	if message.author.id == client.user.id and message.channel.id == config.hearbeatChannel then
		mercy:reset()
		return
	end
end