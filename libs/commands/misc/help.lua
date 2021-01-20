local embeds = require "embeds/embeds"

local articles = {
	help = 0,
	lobbies = 1,
	matchmaking = 2,
	companions = 3,
	room = 4,
	chat = 5,
	server = 6,
	other = 7
}

return function (message)
	local command = (message.content:match("help%s*(.-)$") or "help"):lower()
	if not articles[command] then
		command = "help"
	end
	
	return command.." help message", "help", articles[command]
end