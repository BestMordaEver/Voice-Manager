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
	init = function ()
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
	end,

	ready = function ()
		client:emit("init")
		guilds:cleanup()
		lobbies:cleanup()
		channels:cleanup()
	end
}

return setmetatable(events, {__call = function (self, name, fn)
	return safeEvent(name, fn or self[name])
end})