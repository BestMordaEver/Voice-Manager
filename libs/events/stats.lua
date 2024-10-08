-- stats to different bot boards are sent from here

local https = require "coro-http"
local encode = require "json".encode

local token = require "token"
local config = require "config"
local client = require "client"
local logger = require "logger"
local emitter = require "discordia".Emitter()

local function send (name, server)
	if token.tokens[name] then
		local res, body = https.request("POST",server.endpoint,
			{{"Authorization", token.tokens[name]},{"Content-Type", "application/json"},{"Accept", "application/json"}},
			encode({[server.body] = #client.guilds}))

		if res.code ~= 204 and res.code ~= 200 then
			logger:log(2, "Couldn't send stats to %s - %s", name, body)
		end
	end
end

emitter:on("send", function (name, server)
	local success, err = xpcall(send, debug.traceback, name, server)
	if not success then
		logger:log(1, "Error on %s\n%s", name, err)
		if config.stderr then
			client:getChannel(config.stderr):sendf("Error on %s\n%s", name, err)
		end
	end
end)

local statservers = {
	["discordbotlist.com"] = {
		endpoint = "https://discordbotlist.com/api/v1/bots/"..client.user.id.."/stats",
		body = "guilds"
	},

	["top.gg"] = {
		endpoint = "https://top.gg/api/bots/"..client.user.id.."/stats",
		body = "server_count"
	},

	["discords.com"] = {
		endpoint = "https://discords.com/bots/api/bot/"..client.user.id.."/setservers",
		body = "server_count"
	},

	["bots.ondiscord.xyz"] = {
		endpoint = "https://bots.ondiscord.xyz/bot-api/bots/"..client.user.id.."/guilds",
		body = "guildCount"
	},

	["discord.bots.gg"] = {
		endpoint = "https://discord.bots.gg/api/v1/bots/"..client.user.id.."/stats",
		body = "guildCount"
	},

	["discordlist.gg"] = {
		endpoint = "https://api.discordlist.gg/v0/bots/"..client.user.id.."/guilds",
		body = "count"
	}
}

return function ()
	for name, server in pairs(statservers) do
		emitter:emit("send", name, server)
	end
end