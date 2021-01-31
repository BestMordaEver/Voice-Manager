local client = require "client"
local logger = require "logger"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"
local enforceReservations = require "funcs/enforceReservations"

local permission = require "discordia".enums.permission

return function (member, channel)
	if channel and channels[channel.id] then
		enforceReservations(channel)
	end
end