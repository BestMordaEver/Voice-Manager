local embeds = require "utils/embeds"

return function (message)	-- in case embed gets deleted
	if embeds[message] then embeds[message] = nil end
end