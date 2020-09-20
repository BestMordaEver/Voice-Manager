local locale = require "locale"
local embeds = require "embeds"

return function (message)
	local command = (message.content:match("help%s*(.-)$") or "help"):lower()
	if not (command and locale[command]) then
		command = "help"
	end
	
	embeds:sendHelp(message)
	return command.." help message"
end