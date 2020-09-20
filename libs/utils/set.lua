-- classic set, aware of its size
return setmetatable({},{
	__call = function ()
		return setmetatable({
			n = 0
		},{
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
		})
	end
})