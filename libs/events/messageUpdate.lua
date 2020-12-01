local mercy = require "mercy"
local config = require "config"

return function (message)	-- hearbeat check
	if message.author.id == config.id and message.channel.id == config.hearbeatChannel then
		mercy:reset()
		return
	end
end