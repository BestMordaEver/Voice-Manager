local discordia = require "discordia"
local permissions = discordia.enums.permissions

local bitfield = {
	bits = {
		deafen = 0x01,
		mute = 0x02,
		disconnect = 0x04,
		manage = 0x08,
		name = 0x10,
		capacity = 0x20,
		bitrate = 0x40,
		on = 0x80
	},
	
	perms = {
		[0x01] = "deafen",
		[0x02] = "mute",
		[0x04] = "disconnect",
		[0x08] = "manage",
		[0x10] = "name",
		[0x20] = "capacity",
		[0x40] = "bitrate",
		[0x80] = "on"
	},
	
	has = function (self, permission)
		return bit.band(self.raw, permission) == permission
	end,
	
	toDiscordia = function (self)
		local perms = 
			(self:has(self.deafen) and permissions.deafenMembers or 0) +
			(self:has(self.mute) and permissions.muteMembers or 0) +
			(self:has(self.disconnect) and permissions.moveMembers or 0) +
			(self:has(self.manage) and permissions.manageChannels or 0)
		
		return discordia.Permissions.fromMany(perms)
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
					if self:has(bit) then
						str = str .. name .. " "
					end
				end
				str = str:sub(1,-2)
				return str == "" and "nothing" or str
			end
		})
	end
})