local discordia = require "discordia"
local embeds = require "embeds"
local locale = require "locale"
local lobbies = require "storage/lobbies"

local prefinalizer = require "prefinalizer"
local actionParse = require "utils/actionParse"
local bitfield = require "utils/bitfield"
local truePositionSorting = require "utils/truePositionSorting"
local client = discordia.storage.client
local permission = discordia.enums.permission

return function (message, ids, permissions)
	if not ids then
		local permissionBits = bitfield()
		permissions = message.content:match('permissions%s*".-"%s*(.-)$') or message.content:match('permissions%s*(.-)$')
		
		for name, bits in pairs(permissionBits.bits) do
			if permissions:match(name) then
				permissionBits.raw = permissionBits + bits
			end
		end
		
		permissions = permissionBits.raw
		ids = actionParse(message, message.content:match('"(.-)"'), "permissions", permissions)
		if not ids[1] then return ids end -- message for logger
	end
	
	return prefinalizer.permissions(message, ids, permissions)
end