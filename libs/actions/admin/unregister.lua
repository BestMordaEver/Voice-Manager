local actionParse = require "utils/actionParse"
local prefinalizer = require "prefinalizer"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids)
	local msg
	
	if not ids then
		ids = actionParse(message, message.content:match("unregister%s*(.-)$"), "unregister")
		if not ids[1] then return ids end -- message for logger
	end
	
	return prefinalizer.unregister(message, ids)
end