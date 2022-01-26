-- all event preprocessing happens here
local client = require "client"
local config = require "config"
local clock = require "clock"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local status = require "funcs/status"
local safeEvent = require "funcs/safeEvent"

--[[
events are listed by name here, discordia events may differ from OG discord events for sake of convenience
full list and arguments - https://github.com/SinisterRectus/Discordia/wiki/Events
]]
local events
events = {
	commandInteraction = require "events/commandInteraction",

	componentInteraction = require "events/componentInteraction",

	messageUpdate = require "events/messageUpdate",

	guildCreate = require "events/guildCreate",

	guildDelete = require "events/guildDelete",

	voiceChannelJoin = require "events/voiceChannelJoin",

	voiceChannelLeave = require "events/voiceChannelLeave",

	channelUpdate = require "events/channelUpdate",

	channelDelete = require "events/channelDelete",

	presenceUpdate = require "events/presenceUpdate",

	init = function ()
		guilds:load()
		lobbies:load()
		channels:load()
		clock:start()

		client:setGame(status())
		if config.wakeUpFeed then
			client:getChannel(config.wakeUpFeed):send("I'm listening")
		end

		client:on(events("commandInteraction"))
		client:on(events("componentInteraction"))
		client:on(events("messageUpdate"))
		client:on(events("guildCreate"))
		client:on(events("guildDelete"))
		client:on(events("voiceChannelJoin"))
		client:on(events("voiceChannelLeave"))
		client:on(events("channelUpdate"))
		client:on(events("channelDelete"))
		client:on(events("presenceUpdate"))
		clock:on(events("min"))
		clock:on(events("day"))

		if config.sendStats then clock:on(events("hour", require "events/stats")) end
	end,

	ready = function ()
		client:emit("init")
		guilds:cleanup()
		lobbies:cleanup()
		channels:cleanup()
	end,

	min = require "events/min",

	day = require "events/day",
}

return setmetatable(events, {__call = function (self, name, fn)
	return safeEvent(name, fn or self[name])
end})