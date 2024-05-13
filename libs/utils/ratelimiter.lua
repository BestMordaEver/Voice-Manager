local timer = require "timer"

local Time = require "discordia".Time
local Emitter = require "discordia".Emitter
local logger = require "logger"

local ratelimiter = {}
local emitter = Emitter()

local function reset (name, point, ...)
	ratelimiter[name][point] = nil
	emitter:emit(name, point, ...)
end

return setmetatable(ratelimiter,{
	__index = {
		-- returns remaining attempts and tostring of how much time left until ratelimit is reset
		limit = function (self, name, point, ...)
			if not self[name] then error ("No ratelimits on event "..tostring(name)) end

			local limitPoint = self[name][point]

			if not limitPoint then
				self[name][point] = {remaining = self[name].limit - 1, resetAfter = os.time() + self[name].timer}
				limitPoint = self[name][point]
				timer.setTimeout(self[name].timer * 1000, reset, name, point, ...)
				logger:log(4, "EVENT %s ENDPOINT %s: ratelimiting for %s, %s tries left", name, point, Time.fromSeconds(self[name].timer):toString(), limitPoint.remaining)
			elseif limitPoint.remaining > 0 then
				limitPoint.remaining = limitPoint.remaining - 1
				logger:log(4, "EVENT %s ENDPOINT %s: ratelimiting for %s, %s tries left", name, point, Time.fromSeconds(limitPoint.resetAfter - os.time()):toString(), limitPoint.remaining)
			else
				logger:log(4, "EVENT %s ENDPOINT %s: ratelimit hit for %s", name, point, Time.fromSeconds(limitPoint.resetAfter - os.time()):toString())
				return -1, Time.fromSeconds(limitPoint.resetAfter - os.time()):toString()
			end

			return limitPoint.remaining, Time.fromSeconds(limitPoint.resetAfter - os.time()):toString()
		end,

		on = function (self, name, f)
			return emitter:on(name, f)
		end
	},

	__call = function (self, name, limit, timer)
		self[name] = setmetatable({},{__index = {limit = limit, timer = timer}})
	end
})