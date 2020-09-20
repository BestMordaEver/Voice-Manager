-- all event preprocessing happens here
local discordia = require "discordia"
local client, logger, clock = discordia.storage.client, discordia.storage.logger, discordia.storage.clock

local channels = require "storage/channels"
local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"
local status = require "utils/status"

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
	
	reactionRemove = require "events/reactionRemove",
	
	guildCreate = require "events/guildCreate",
	
	guildDelete = require "events/guildDelete",
	
	voiceChannelJoin = require "events/voiceChannelJoin",
	
	voiceChannelLeave = require "events/voiceChannelLeave",
	
	channelDelete = require "events/channelDelete",
	
	ready = function ()
		channels:load()
		lobbies:load()
		guilds:load()
		clock:start()
		
		client:setGame(status())
		client:getChannel("676432067566895111"):send("I'm listening")
		
		client:on(events("messageCreate"))
		client:on(events("messageUpdate"))
		client:on(events("reactionAdd"))
		client:on(events("reactionRemove"))
		client:on(events("guildCreate"))
		client:on(events("guildDelete"))
		client:on(events("voiceChannelJoin"))
		client:on(events("voiceChannelLeave"))
		client:on(events("channelDelete"))
		clock:on(events("min"))
		clock:on(events("hour"))
	end,

	min = require "events/min",
	
	hour = require "events/hour"
}

local function safeEvent (self, name)
	-- will be sent to emitter:on() style function
	-- name corresponds to event name
	-- function starts protected calls of event responding functions from "events"
	return name, function (...)
		local success, err = xpcall(self[name], debug.traceback, ...)
		if not success then
			logger:log(1, "Error on %s: %s", name, err)
			client:getChannel("686261668522491980"):sendf("Error on %s: %s", name, err)
		end
	end
end

return setmetatable(events, {__call = safeEvent})