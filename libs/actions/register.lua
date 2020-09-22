local actionParse = require "utils/actionParse"
local finalizer = require "finalizer"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids)
	local msg
	
	if not ids then
		ids = actionParse(message, message.content:match("register%s*(.-)$"), "register")
		if not ids[1] then return ids end -- message for logger
	end
	
	msg, ids = finalizer.register(message, ids)
	message:reply(msg)
	return (#ids == 0 and "Successfully registered all" or ("Couldn't register "..table.concat(ids, " ")))
end