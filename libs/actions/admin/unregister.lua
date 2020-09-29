local actionParse = require "utils/actionParse"
local finalizer = require "finalizer"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids)
	local msg
	
	if not ids then
		ids = actionParse(message, message.content:match("unregister%s*(.-)$"), "unregister")
		if not ids[1] then return ids end -- message for logger
	end
	
	msg, ids = finalizer.unregister(message, ids)
	message:reply(msg)
	return (#ids == 0 and "Successfully unregistered all" or ("Couldn't unregister "..table.concat(ids, " ")))
end