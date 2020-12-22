local channels = require "storage/channels"
local lobbies = require "storage/lobbies"
local client = require "client"

--[[
status generating function
cycles 3 different metrics every minute
bots still can't do custom statuses ;^;
]]
return function ()
	local self = {
	-- type - see enumeration activityType (https://github.com/SinisterRectus/Discordia/wiki/Enumerations), determines first word
	-- name - everything after first word
	}

	-- determine the cycle
	local step = math.fmod(os.date("*t").min, 4)
	
	if step == 0 then -- people
		local people = channels:people()
		
		self.name =
			people == 0 and "the sound of silence" or (
			people .. (
				people == 1 and " person" or " people") .. (
				tostring(people):match("69") and " (nice!)" or ""))
		
		self.type = 2
		
	elseif step == 1 then -- channels
		local channels = #channels
		
		self.name =
			channels == 0 and "the world go by" or (
			"over "..channels .. (
				channels == 1 and " channel" or " channels") .. (
				tostring(channels):match("69") and " (nice!)" or ""))
		
		self.type = 3
		
	elseif step == 2 then -- lobbies
		local lobbies = #lobbies
		
		self.name =
			lobbies == 0 and "the world go by" or (
			"over "..lobbies .. (
				lobbies == 1 and " lobby" or " lobbies") .. (
				tostring(lobbies):match("69") and " (nice!)" or ""))
		
		self.type = 3
	elseif step == 3 then -- guilds
		local guilds = #client.guilds
		
		self.name =
			guilds == 0 and "the world go by" or (
			"over "..guilds .. (
				guilds == 1 and " server" or " servers") .. (
				tostring(guilds):match("69") and " (nice!)" or ""))
		
		self.type = 3
	end
	return self
end