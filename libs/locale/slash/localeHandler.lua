local enUS = require "locale/slash/en-US"

local handler = {
	["en-US"] = enUS
}

local meta = {
-- [=[
	__index = function (self, k)
		return assert(enUS[k], k .. " - not a valid line!")
	end,
--[[]=]
	__index = function (self, k)
		if not enUS[k] then print(k) end
		return enUS[k]
	end,
--]]
	__call = function (self, loc, line)
		return (self[loc] and self[loc][line]) or enUS[line]
	end
}

return setmetatable(handler, meta)