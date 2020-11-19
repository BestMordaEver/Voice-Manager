local actionParse = require "utils/actionParse"
local prefinalizer = require "prefinalizer"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids)
	local msg
	
	if not ids then
		ids = actionParse(message, message.content:match("register%s*(.-)$"), "register")
		if not ids[1] then return ids end -- message for logger
	end
	
	return prefinalizer.register(message, ids)
end