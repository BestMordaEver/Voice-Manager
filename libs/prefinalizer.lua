local discordia = require "discordia"
local locale = require "locale"
local finalizer = require "finalizer"
local lobbies = require "storage/lobbies"
local bitfield = require "utils/bitfield"

local client = discordia.storage.client

local function new (action, probing)
	return function (message, ids, argument)
		if probing then 
			local res = probing(message, ids, argument)
			if res then return res end
		end
		
		argument, ids = finalizer[action](message, ids, argument)
		message:reply(argument)
		return (#ids == 0 and "Successfully completed action for all" or ("Couldn't complete action for "..table.concat(ids, " ")))
	end
end

return {
	register = new("register"),
	
	unregister = new("unregister"),
	
	template = new("template", function (message, ids, template)
		if template == "" then
			message:reply(lobbies[ids[1]].template and locale.lobbyTemplate:format(client:getChannel(ids[1]).name, lobbies[ids[1]].template) or locale.noTemplate)
			return "Sent channel template"
		end
	end),
	
	target = new("target", function (message, ids, target)
		target = target or ""
	
		if target == "" then
			message:reply(lobbies[ids[1]].target and locale.lobbyTarget:format(client:getChannel(ids[1]).name, client:getChannel(lobbies[ids[1]].target).name) or locale.noTarget)
			return "Sent channel target"
		end
	end),
	
	permissions = new("permissions", function (message, ids, permissions)
		if permissions == 0 then
			message:reply(locale.lobbyPermissions:format(client:getChannel(ids[1]).name, tostring(bitfield(lobbies[ids[1]].permissions))))
			return "Sent channel permissions"
		end
	end),
	
	capacity = new("capacity", function (message, ids, capacity)
		if not capacity then
			message:reply(lobbies[ids[1]].capacity and locale.lobbyCapacity:format(client:getChannel(ids[1]).name, lobbies[ids[1]].capacity) or locale.noCapacity)
			return "Sent channel capacity"
		end
	end)
}