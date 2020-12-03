local locale = require "locale"
local embeds = require "embeds"

return function (message)
	local command = (message.content:match("help%s*(.-)$") or "help"):lower()
	if not (command and locale[command]) then
		command = "help"
	end
	
	if command == "help" then
		embeds.embedTypes.help(message)
	else
		message:reply({embed = {
			title = "Help | " .. command:gsub("^.", string.upper, 1),	-- upper bold text
			color = 6561661,
			description = locale[command]..locale.links,
			footer = {text = command ~= "help" and locale.embedTip or nil}
		}})
	end
	
	return command.." help message"
end