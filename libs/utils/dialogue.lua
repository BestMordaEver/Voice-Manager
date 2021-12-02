local timer = require "timer"
local timers = {}

local function clear (self, userID)
	self[userID] = nil
	timers[userID] = nil
end

return setmetatable({},{
	__call = function (self, userID, selected)
		-- new dialogues with the user nullify previous ones
		self[userID] = selected
		if timers[userID] then
			timer.clearTimeout(timers[userID])
		end
		timers[userID] = timer.setTimeout(3000000, clear, self, userID)
	end,

	__index = {clear = clear}
})