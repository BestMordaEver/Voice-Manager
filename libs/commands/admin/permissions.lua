local client = require "discordia".storage.client
local commandParse = require "commands/commandParse"
local commandFinalize = require "commands/commandFinalize"
local bitfield = require "utils/bitfield"

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
		ids = commandParse(message, message.content:match('"(.-)"'), "permissions", permissions)
		if not ids[1] then return ids end -- message for logger
	end
	
	return commandFinalize.permissions(message, ids, permissions)
end