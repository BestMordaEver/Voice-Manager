local bitfield = {
	has = function (self, bits)
		return bit.band(self.value, bits) == bits
	end
}

return setmetatable(bitfield,{
	__call = function (self, init)
		return setmetatable({
			value = init or 0
		},{
			__add = function (left, right)
				return bitfield(bit.bor(left.value, tonumber(right) and right or right.value))
			end,
			
			__sub = function (left, right)
				return bitfield(bit.band(left.value, bit.bnot(tonumber(right) and right or right.value)))
			end,
			
			__index = function (self, key)
				if tonumber(key) then
					if key > 64 or key < 1 then
						error("Out of bounds - trying to access \""..tostring(key).."\" bit")
					else
						return bit.band(self.value, 2^(key-1)) ~= 0
					end
				else
					return bitfield[key]
				end
			end
		})
	end
})