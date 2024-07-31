--[[
luvit redefines lua's require
"packageName" must be in luvit's local "deps" or entry point's "libs" folder
"./filename.lua" may be anywhere, just make sure the path is fine

require "discordia"								table: 0x02563805ddf8
require "../deps/discordia/init.lua"			table: 0x02563805ddf8
require "D:\\lua\\deps\\discordia\\init.lua"	table: 0x025638037e88 absolute path is a bitch i guess :/
]]
local discordia = require "discordia"

-- copy and sorted are nice
discordia.extensions.table()

-- prepends a % in front of any lua magic symbol, used in complicated name processing
string.demagic = function (s)
	return s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1"), nil
end

-- converts a string to discord text channel convention
string.discordify = function (s)
	return s:gsub("[%s%-~]+","-"):gsub("^%-+",""):gsub("[\\%!\"#%$&%*%+,%./:;<=>%?@%[%]%^`{|}]",""):gsub("%-+","-"):lower()
	--return s:gsub("[%s%-~]+","-"):gsub("^%-+",""):gsub("[\\\'%%%(%)%!\"#%$&%*%+,%./:;<=>%?@%[%]%^`{|}]",""):gsub("%-+","-"):lower()
	-- \'%%%(%) is omitted to allow name templates to work properly
end

local intents = discordia.enums.gatewayIntent
local client = discordia.Client{
	gatewayIntents =
		intents.guilds +
		intents.guildVoiceStates +
		intents.guildPresences +
		intents.guildMessages +
		intents.guildMessageReactions +
		intents.messageContent +
		intents.directMessage
}

local clock = discordia.Clock()

-- creating stubs for require to easily access all relevant bits without making them global
package.loaded.client = client
package.loaded.clock = clock
package.loaded.logger = discordia.Logger(6, '%F %T')

local config = require "config"

local storage = require "handlers/storageHandler"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local status = require "handlers/statusHandler"
local safeEvent = require "utils/safeEvent"

-- pre-load db
storage:load()

-- this will load in guilds and all related data
client:on(safeEvent("guildAvailable", function (guild)
	if not guilds[guild.id] then storage.loadGuild(guild) end
end))

-- once all guilds are loaded, this event will fire
-- ready triggers every reconnection, so it needs to run only once
client:once(safeEvent("ready", function ()
	storage:cleanup()
	clock:start()

	if config.wakeUpFeed then
		client:getChannel(config.wakeUpFeed):send("I'm listening")
	end

	require "utils/mercy".initialize(client.shardCount)

	client:on(safeEvent("commandInteraction", require "events/commandInteraction"))
	client:on(safeEvent("componentInteraction", require "events/componentInteraction"))
	client:on(safeEvent("modalInteraction", require "events/modalInteraction"))
	client:on(safeEvent("guildCreate", require "events/guildCreate"))
	client:on(safeEvent("guildDelete", require "events/guildDelete"))
	client:on(safeEvent("voiceChannelJoin", require "events/voiceChannelJoin"))
	client:on(safeEvent("voiceChannelLeave", require "events/voiceChannelLeave"))
	client:on(safeEvent("channelDelete", require "events/channelDelete"))
	client:on(safeEvent("presenceUpdate", require "events/presenceUpdate"))
	client:on(safeEvent("heartbeat", require "events/heartbeat"))
	clock:on(safeEvent("min", require "events/min"))
	clock:on(safeEvent("day", require "events/day"))

	if config.sendStats then clock:on(safeEvent("hour", require "events/stats")) end

	storage.stats.lobbies = #lobbies
	storage.stats.channels = #channels
	storage.stats.users = channels:users()
	client:setActivity(status())

	guilds:cleanup()
	lobbies:cleanup()
	channels:cleanup()
end))

-- bot starts working here
client:run('Bot '..require "token".token)