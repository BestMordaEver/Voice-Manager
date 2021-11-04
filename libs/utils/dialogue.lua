local timer = require "timer"
local timers = {}

local function clear (self, selected)
	self[selected] = nil
	timers[selected] = nil
end

return setmetatable({},{
	__call = function (self, userID, selected)
		-- new dialogues with the user nullify previous ones
		self[selected] = userID
		if timers[selected] then
			timer.clearTimeout(timers[selected])
		end
		timers[selected] = timer.setTimeout(3000000, clear, self, selected)
	end,
	
	__index = {clear = clear}
})