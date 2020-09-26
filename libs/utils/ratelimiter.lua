local timer = require "timer"

local discordia = require "discordia"
local Time = discordia.Time
local logger = discordia.storage.logger
local safeEvent = require "utils/safeEvent"

local ratelimiter = {}

local function reset (name, point)
	ratelimiter[name][point] = nil
end

return setmetatable(ratelimiter,{
	__index = {
		-- returns remeaining attempts and tostring of how much time left until ratelimit is reset
		limit = function (self, name, point)
			if not self[name] then error ("No ratelimits on event "..tostring(name)) end
			
			local limitPoint = self[name][point]
			
			if not limitPoint then
				self[name][point] = {remaining = self[name].limit - 1, resetAfter = os.time() + self[name].timer}
				limitPoint = self[name][point]
				timer.setTimeout(self[name].timer * 1000, reset, name, point)
				logger:log(4, "Ratelimiting event %s endpoint %s for %s, %s tries left", name, point, Time.fromSeconds(self[name].timer):toString(), limitPoint.remaining)
			elseif limitPoint.remaining > 0 then
				limitPoint.remaining = limitPoint.remaining - 1
				logger:log(4, "Ratelimiting event %s endpoint %s for %s, %s tries left", name, point, Time.fromSeconds(limitPoint.resetAfter - os.time()):toString(), limitPoint.remaining)
			else
				logger:log(4, "Ratelimit hit on event %s endpoint %s for %s", name, point, Time.fromSeconds(limitPoint.resetAfter - os.time()):toString())
				return -1, Time.fromSeconds(limitPoint.resetAfter - os.time()):toString()
			end
			
			return limitPoint.remaining, Time.fromSeconds(limitPoint.resetAfter - os.time()):toString()
		end
	},
	
	__call = function (self, name, limit, timer)
		self[name] = setmetatable({},{__index = {limit = limit, timer = timer}})
	end
})