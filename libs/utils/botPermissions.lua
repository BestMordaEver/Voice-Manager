local bitfield = require "utils/bitfield"
local permission = require "discordia".enums.permission

local botPermissions

local botPermissionsMT = {
	__index = {
		bits = {
			--superhost = 0x0001,
			mute      = 0x0002,
			moderate  = 0x0004,
			manage    = 0x0008,
			rename    = 0x0010,
			resize    = 0x0020,
			bitrate   = 0x0040,
			--unmute    = 0x0080,
			kick      = 0x0100,
			hide      = 0x0200,
			--show      = 0x0400,
			lock      = 0x0800,
			--unlock    = 0x1000,
			password  = 0x2000,
		},

		perms = {
			--[0x0001] = "superhost",
			[0x0002] = "mute",
			[0x0004] = "moderate",
			[0x0008] = "manage",
			[0x0010] = "rename",
			[0x0020] = "resize",
			[0x0040] = "bitrate",
			--[0x0080] = "unmute",
			[0x0100] = "kick",
			[0x0200] = "hide",
			--[0x0400] = "show",
			[0x0800] = "lock",
			--[0x1000] = "unlock",
			[0x2000] = "password"
		},

		toDiscordia = function (self)
			local perms = {}
			if self.bitfield:has(self.bits.moderate) or self.bitfield:has(self.bits.kick) then table.insert(perms, permission.moveMembers) end
			if self.bitfield:has(self.bits.manage) then
				table.insert(perms, permission.manageChannels)
				table.insert(perms, permission.manageRoles)
			end

			return perms
		end,

		has = function (self, permission)
			return (self.bits[permission] or tonumber(permission)) and self.bitfield:has(self.bits[permission] or tonumber(permission)) or false
		end,

		value = function (self)
			return self.bitfield.value
		end
	},

	__add = function (left, right)
		return botPermissions((left.bitfield + right.bitfield).value)
	end,

	__sub = function (left, right)
		return botPermissions((left.bitfield - right.bitfield).value)
	end,

	__tostring = function (self)
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

botPermissions = function (perms)
	return setmetatable({bitfield = bitfield(perms)},botPermissionsMT)
end

return botPermissions