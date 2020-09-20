local registerParse = require "actions/registerParse"
local actionFinalizer = require "finalizers/register"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids)
	local msg
	
	if not ids then
		ids = registerParse(message, "register")
		if not ids[1] then return ids end -- message for logger
	end
	
	msg, ids = actionFinalizer(message, ids, "register")
	message:reply(msg)
	return (#ids == 0 and "Successfully registered all" or ("Couldn't register "..table.concat(ids, " ")))
end