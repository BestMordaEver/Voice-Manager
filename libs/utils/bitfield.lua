local discordia = require "discordia"
local permissions = discordia.enums.permissions
local 

local bitfield = {
	deafen = 0x01,
	mute = 0x02,
	disconnect = 0x04,
	manage = 0x08,
	name = 0x10,
	capacity = 0x20,
	bitrate = 0x40,
	on = 0x80,
	
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
	__call = function ()
		return setmetatable({
			raw = 0
		},{
			__add = function (left, right)
				return bit.bor(left.raw, right.raw)
			end,
			
			__sub = function (left, right)
				return bit.xor(left.raw, right.raw)
			end,
			
			__index = function (self, key)
				key = tonumber(key)
				if tonumber(key) then
					if key > 8 or key < 1 then
						error("Out of bounds - trying to access \""..tostring(key).."\" bit")
					else
						return bit.band(self.raw, 2^(key-1)) ~= 0
					end
				else
					return bitfield[key]
				end
			end
		})
	end
})