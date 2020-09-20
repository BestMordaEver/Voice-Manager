local registerParse = require "actions/registerParse"
local actionFinalizer = require "finalizers/unregister"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids)
	local msg
	
	if not ids then
		ids = registerParse(message, "unregister")
		if not ids[1] then return ids end -- message for logger
	end
	
	msg, ids = actionFinalizer(message, ids, "unregister")
	message:reply(msg)
	return (#ids == 0 and "Successfully unregistered all" or ("Couldn't unregister "..table.concat(ids, " ")))
end