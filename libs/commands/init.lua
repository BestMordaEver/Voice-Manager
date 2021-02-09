local embeds = require "embeds/embeds"

local function invite (message)
	return "Sent support invite", "invite", "https://discord.gg/tqj6jvT"
end

-- all possible bot commands are processed in corresponding files, should return message for logger
return {
	help = require "commands/misc/help",
	select = require "commands/misc/select",
	server = require "commands/server/server",
	lobbies = require "commands/lobbies/lobbies",
	companions = require "commands/companions/companions",
	matchmaking = require "commands/matchmaking/matchmaking",
	room = require "commands/room/room",
	chat = require "commands/chat/chat",
	shutdown = require "commands/misc/shutdown",
	support = invite,
	invite = invite
}