local discordia = require "discordia"
local embeds = require "embeds"
local locale = require "locale"
local lobbies = require "storage/lobbies"

local finalizer = require "finalizer"
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
		
		--[[
		if permissionBits.raw == 0 then
			message:reply(locale.noPermission)
			return "No permission was selected"
		end
		
		if not (ids or permissions:match("on") or permissions:match("off")) then	-- TODO: embedded toggle
			message:reply(locale.noToggle)
			return "No toggle was selected"
		end
		--]]
		
		permissions = permissionBits.raw
		ids = actionParse(message, message.content:match('"(.-)"'), "permissions", permissions)
		if not ids[1] then return ids end -- message for logger
	end
	
	if permissions == 0 then
		message:reply(locale.lobbyPermissions:format(client:getChannel(ids[1]).name, tostring(bitfield(lobbies[ids[1]].permissions))))
		return "Sent channel permissions"
	end
	
	permission, ids = finalizer.permissions(message, ids, permissions)
	message:reply(permission)
	return (#ids == 0 and "Successfully applied permission to all" or ("Couldn't apply permission to "..table.concat(ids, " ")))
end