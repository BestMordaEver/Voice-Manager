local locale = require "locale"
local helpEmbed = require "embeds/help"

return function (message)
	local command = (message.content:match("help%s*(.-)$") or "help"):lower()
	if not (command and locale[command]) then
		command = "help"
	end
	
	if command == "help" then
		helpEmbed(message)
	end
	
	return command.." help message"
end