local embeds = require "embeds/embeds"

local function invite (message)
	return "Sent support invite", "asIs", "https://discord.gg/tqj6jvT"
end

local function code (s)
	return string.format("```\n%s```", s)
end

local sandbox = setmetatable({
	client = require "client",
	guilds = require "storage/guilds",
	lobbies = require "storage/lobbies",
	channels = require "storage/channels"
},{ __index = _G})

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
	invite = invite,
	exec = function (message)
		if message.author ~= message.client.owner then return end
		
		local fn, syntaxError = load(message.content:match("exec%s*(.-)$"), "Bot", "t", sandbox)
		if not fn then return "Syntax error", "warning", code(syntaxError) end

		local success, runtimeError = pcall(fn)
		if not success then return "Runtime error", "warning", code(runtimeError) end
		
		return "Code executed", "ok", "Code executed"
	end
}