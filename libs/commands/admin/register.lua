local commandParse = require "commands/commandParse"
local commandFinalize = require "commands/commandFinalize"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids)
	local msg
	
	if not ids then
		ids = commandParse(message, message.content:match("register%s*(.-)$"), "register")
		if not ids[1] then return ids end -- message for logger
	end
	
	return commandFinalize.register(message, ids)
end