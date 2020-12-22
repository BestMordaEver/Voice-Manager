local bitfield = require "utils/bitfield"
local permission = require "discordia".enums.permission

return function (perms) 
	return setmetatable({bitfield = bitfield(perms)},{
		__index = {
			bits = {
				--deafen = 0x01,
				mute = 0x02,
				moderate = 0x04,
				manage = 0x08,
				name = 0x10,
				resize = 0x20,
				bitrate = 0x40
			},
			
			perms = {
				--[0x01] = "deafen",
				[0x02] = "mute",
				[0x04] = "moderate",
				[0x08] = "manage",
				[0x10] = "name",
				[0x20] = "resize",
				[0x40] = "bitrate"
			},
			
			toDiscordia = function (self)
				local perms = {}
				if self.bitfield:has(self.bits.moderate) then table.insert(perms, permission.moveMembers) end
				if self.bitfield:has(self.bits.manage) then table.insert(perms, permission.manageChannels) end
				
				return perms
			end,
			
			tostring = function (self)
				local str = ""
				for bit, name in pairs(self.perms) do
					if self.bitfield:has(bit) then
						str = str .. name .. " "
					end
				end
				str = str:sub(1,-2)
				return str == "" and "nothing" or str
			end
		}
	})
end