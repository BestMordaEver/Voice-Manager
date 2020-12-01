-- all event preprocessing happens here
local discordia = require "discordia"
local client, logger, clock = discordia.storage.client, discordia.storage.logger, discordia.storage.clock

local channels = require "storage/channels"
local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"
local status = require "utils/status"
local safeEvent = require "utils/safeEvent"
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
	
	channelDelete = require "events/channelDelete",
	
	ready = function ()
		lobbies:load()
		channels:load()
		guilds:load()
		clock:start()
		
		client:setGame(status())
		if config.guildFeed then
			client:getChannel(config.guildFeed):send("I'm listening")
		end
		
		client:on(events("messageCreate"))
		client:on(events("messageUpdate"))
		client:on(events("reactionAdd"))
		client:on(events("guildCreate"))
		client:on(events("guildDelete"))
		client:on(events("voiceChannelJoin"))
		client:on(events("voiceChannelLeave"))
		client:on(events("channelDelete"))
		clock:on(events("min"))
		
		if config.sendStats then clock:on(events("hour")) end
	end,

	min = require "events/min",
	
	hour = require "events/hour"
}

return setmetatable(events, {__call = function (self, name)
	return safeEvent(name, self[name])
end})