-- array, that allows and processes holes
local Mutex = require "discordia".Mutex

local hollowMT = {
	__index = {
		fill = function (self, o, pos)
			self.mutex:lock()
			pos = pos or self.space	-- pos may be nil
			if self[pos] == nil then self.n = self.n + 1 end
			self[pos] = o
			if pos > self.max then self.max = pos end
			while self[self.space] ~= nil do self.space = self.space + 1 end
			self.mutex:unlock()
			return pos
		end,

		drain = function (self, pos)
			if self[pos] == nil then return end

			self.mutex:lock()
			local ret = self[pos]
			self[pos] = nil
			self.n = self.n - 1
			if pos < self.space then self.space = pos end
			while self[self.max] == nil and self.max > 0 do self.max = self.max - 1 end
			self.mutex:unlock()
			return ret
		end
	},
	__len = function (self) return self.n end,
	__pairs = function (self)
		return function (t, index)
			if not index then index = 0 end
			index = index + 1

			repeat
				if t[index] then
					return index, t[index]
				else
					index = index + 1
				end
			until index > t.max

			return nil
		end, self
	end
}

return function ()
	return setmetatable({n = 0, space = 1, max = 0, mutex = Mutex()},hollowMT)
end