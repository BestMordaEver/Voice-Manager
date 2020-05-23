local discordia = require "discordia"
local client = discordia.Client()
local clock = discordia.Clock()
discordia.storage = {client = client, clock = clock, logger = discordia.Logger(4, '%F %T')}

local config = require "./config.lua"
local events = require "./events.lua"

client:on(events("messageCreate"))
client:on(events("messageUpdate"))
client:on(events("reactionAdd"))
client:on(events("reactionRemove"))
client:on(events("guildCreate"))
client:on(events("guildDelete"))
client:on(events("voiceChannelJoin"))
client:on(events("voiceChannelLeave"))
client:on(events("channelDelete"))
client:on(events("ready"))
clock:on(events("min"))
clock:on(events("hour"))

client:run('Bot '..config.token)
