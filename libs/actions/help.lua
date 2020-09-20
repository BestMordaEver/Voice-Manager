local locale = require "locale"

return function (message)
	local command = (message.content:match("help%s*(.-)$") or "help"):lower()
	if not (command and locale[command]) then
		command = "help"
	end
	
	message:reply({embed = {
		title = command:gsub("^.", string.upper, 1),	-- upper bold text
		color = 6561661,
		description = locale[command],
		footer = {text = command ~= "help" and locale.embedTip or nil}
	}})
	return command.." help message"
end