-- classic set, aware of its size
local setMT = {
	__index = {
		add = function (self, o)
			if self[o] then return end

			self[o] = true
			self.n = self.n + 1
		end,

		remove = function (self, o)
			if not self[o] then return end

			self[o] = nil
			self.n = self.n - 1
		end,

		random = function (self)
			local index, key = math.random(self.n)

			repeat
				index = index - 1
				key = next(self, key)
				if key == "n" then key = next(self, key) end
			until index <= 1

			return key
		end
	},
	__len = function (self) return self.n end,
	__pairs = function (self)
		return function (t, index)
			local k = next(t, index)
			if k == "n" then k = next(t,k) end
			return k
		end, self
	end
}

return function (init)
	local set = setmetatable({n = 0},setMT)
	for k, _ in pairs(init) do
		set:add(k)
	end
	return set
end