local finalizer = require "finalizer"

return function (message)	-- hearbeat check
	if message.author.id == "601347755046076427" and message.channel.id == "676791988518912020" then
		finalizer:reset()
		return
	end
end