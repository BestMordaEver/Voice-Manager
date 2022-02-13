--[[
luvit redefines lua's require
"packageName" must be in luvit's local "deps" or entry point's "libs" folder
"./filename.lua" may be anywhere, just make sure the path is fine

require "discordia"								table: 0x02563805ddf8
require "../deps/discordia/init.lua"			table: 0x02563805ddf8
require "D:\\lua\\deps\\discordia\\init.lua"	table: 0x025638037e88 absolute path is a bitch i guess :/
]]
local discordia = require "discordia"
discordia.extensions.table()
string.demagic = function (s)
	return s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1"), nil
end

string.discordify = function (s)
	return s:gsub("[%s%-~]+","-"):gsub("^%-+",""):gsub("[\\%!\"#%$&%*%+,%./:;<=>%?@%[%]%^`{|}]",""):gsub("%-+","-"):lower()
	--return s:gsub("[%s%-~]+","-"):gsub("^%-+",""):gsub("[\\\'%%%(%)%!\"#%$&%*%+,%./:;<=>%?@%[%]%^`{|}]",""):gsub("%-+","-"):lower()
	-- \'%%%(%) is omitted to allow name templates to work properly
end

local intents = discordia.enums.gatewayIntent
local client = discordia.Client{
	intents =
		intents.guilds +
		intents.guildMembers +
		intents.guildVoiceStates +
		intents.guildPresences +
		intents.guildMessages +
		intents.guildMessageReactions
}

local clock = discordia.Clock()

-- creating stubs for require to easily access all relevant bits without making them global
package.loaded.client = client
package.loaded.clock = clock
package.loaded.logger = discordia.Logger(6, '%F %T')

local config = require "config"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local status = require "funcs/status"
local safeEvent = require "funcs/safeEvent"

client:onceSync(safeEvent("init", function ()
	guilds:load()
	lobbies:load()
	channels:load()
	clock:start()

	client:setGame(status())
	if config.wakeUpFeed then
		client:getChannel(config.wakeUpFeed):send("I'm listening")
	end

	client:on(safeEvent("commandInteraction", require "events/commandInteraction"))
	client:on(safeEvent("componentInteraction", require "events/componentInteraction"))
	client:on(safeEvent("messageUpdate", require "events/messageUpdate"))
	client:on(safeEvent("guildCreate", require "events/guildCreate"))
	client:on(safeEvent("guildDelete", require "events/guildDelete"))
	client:on(safeEvent("voiceChannelJoin", require "events/voiceChannelJoin"))
	client:on(safeEvent("voiceChannelLeave", require "events/voiceChannelLeave"))
	client:on(safeEvent("channelUpdate", require "events/channelUpdate"))
	client:on(safeEvent("channelDelete", require "events/channelDelete"))
	client:on(safeEvent("presenceUpdate", require "events/presenceUpdate"))
	clock:on(safeEvent("min", require "events/min"))
	clock:on(safeEvent("day", require "events/day"))

	if config.sendStats then clock:on(safeEvent("hour", require "events/stats")) end
end))

client:onceSync(safeEvent("ready", function ()
	client:emit("init")
	guilds:cleanup()
	lobbies:cleanup()
	channels:cleanup()
end))

local timer = require "timer"
timer.setTimeout(180000, client.emit, client, "init")

-- bot starts working here
client:run('Bot '..require "token".token)