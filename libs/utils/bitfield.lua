local discordia = require "discordia"
local permission = discordia.enums.permission

local bitfield = {
	bits = {
		--deafen = 0x01,
		mute = 0x02,
		moderate = 0x04,
		manage = 0x08,
		name = 0x10,
		resize = 0x20,
		bitrate = 0x40,
		on = 0x80
	},
	
	perms = {
		--[0x01] = "deafen",
		[0x02] = "mute",
		[0x04] = "moderate",
		[0x08] = "manage",
		[0x10] = "name",
		[0x20] = "resize",
		[0x40] = "bitrate",
		[0x80] = "on"
	},
	
	has = function (self, permissions)
		return bit.band(self.raw, permissions) == permissions
	end,
	
	toDiscordia = function (self)
		local perms = {}
		if self:has(self.bits.moderate) then table.insert(perms, permission.moveMembers) end
		if self:has(self.bits.manage) then table.insert(perms, permission.manageChannels) end
		
		return perms
	end
}

return setmetatable({},{
	__call = function (self, init)
		return setmetatable({
			raw = init or 0
		},{
			__add = function (left, right)
				return bit.bor(left.raw, tonumber(right) and right or right.raw)
			end,
			
			__sub = function (left, right)
				return bit.band(left.raw, bit.bnot(tonumber(right) and right or right.raw))
			end,
			
			__index = function (self, key)
				if tonumber(key) then
					if key > 8 or key < 1 then
						error("Out of bounds - trying to access \""..tostring(key).."\" bit")
					else
						return bit.band(self.raw, 2^(key-1)) ~= 0
					end
				else
					return bitfield[key]
				end
			end,
			
			__tostring = function (self)
				local str = ""
				for bit, name in pairs(self.perms) do
					if name ~= "on" and self:has(bit) then
						str = str .. name .. " "
					end
				end
				str = str:sub(1,-2)
				return str == "" and "nothing" or str
			end
		})
	end
})