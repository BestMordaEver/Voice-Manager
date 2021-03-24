-- all event preprocessing happens here
local discordia = require "discordia"
local client = require "client"
local logger = require "logger"
local clock = require "clock"
local timer = require "timer"

local channels = require "storage/channels"
local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"
local status = require "funcs/status"
local safeEvent = require "funcs/safeEvent"
local config = require "config"

--[[
events are listed by name here, discordia events may differ from OG discord events for sake of convenience
full list and arguments - https://github.com/SinisterRectus/Discordia/wiki/Events
]]
local events
events = {
	messageCreate = require "events/messageCreate",
	
	messageUpdate = require "events/messageUpdate",
	
	messageDelete = require "events/messageDelete",
	
	reactionAdd = require "events/reactionAdd",
	
	guildCreate = require "events/guildCreate",
	
	guildDelete = require "events/guildDelete",
	
	voiceChannelJoin = require "events/voiceChannelJoin",
	
	voiceChannelLeave = require "events/voiceChannelLeave",
	
	channelUpdate = require "events/channelUpdate",
	
	channelDelete = require "events/channelDelete",
	
	ready = function ()
		timer.clearInterval(discordia.storage.killswitch)
		guilds:load()
		lobbies:load()
		channels:load()
		clock:start()
		
		client:setGame(status())
		if config.wakeUpFeed then
			client:getChannel(config.wakeUpFeed):send("I'm listening")
		end
		
		client:on(events("messageCreate"))
		client:on(events("messageUpdate"))
		client:on(events("reactionAdd"))
		client:on(events("guildCreate"))
		client:on(events("guildDelete"))
		client:on(events("voiceChannelJoin"))
		client:on(events("voiceChannelLeave"))
		client:on(events("channelUpdate"))
		client:on(events("channelDelete"))
		clock:on(events("min"))
		clock:on(events("day"))
		
		if config.sendStats then clock:on(events("hour", require "events/stats")) end
	end,

	min = require "events/min",
	
	day = require "events/day",
}

return setmetatable(events, {__call = function (self, name, fn)
	return safeEvent(name, fn or self[name])
end})