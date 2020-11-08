local client = require "discordia".storage.client
local lobbies = require "storage/lobbies"
local actionParse = require "utils/actionParse"
local finalizer = require "finalizer"
local locale = require "locale"

-- this function is also used by embeds, they will supply ids and capacity value
return function (message, ids, capacity)
	if not ids then
		capacity = tonumber(message.content:match('capacity%s*".-"%s*(.-)$') or message.content:match("capacity%s*(.-)$"))
		
		if not capacity or capacity > 99 or capacity < -1 then
			message:reply(locale.capacityOOB)
			return "Capacity OOB"
		end
		
		ids = actionParse(message, message.content:match('"(.-)"'), "capacity", capacity)
		if not ids[1] then return ids end -- message for logger
	end
	
	if not capacity then
		message:reply(lobbies[ids[1]].capacity and locale.lobbyCapacity:format(client:getChannel(ids[1]).name, lobbies[ids[1]].capacity) or locale.noCapacity)
		return "Sent channel capacity"
	end
	
	capacity, ids = finalizer.capacity(message, ids, capacity)
	message:reply(capacity)
	return (#ids == 0 and "Successfully applied capacity to all" or ("Couldn't apply capacity to "..table.concat(ids, " ")))
end