local client = require "client"

local stats = require "storage/handler".stats

local format = string.format

--[[
status generating function
cycles 3 different metrics every minute
]]
return function ()
	local self = {name = "Custom status", type = 4}

	-- determine the cycle
	local step = math.fmod(os.date("*t").min, 4)

	if step == 0 then -- people
		local users = stats.users

		self.state =
			users == 0
				and
			"Listening to the sound of silence"
				or (
			users == 1
				and
			"Listening to 1 person"
				or
			format("Listening to %d people", users) .. (tostring(users):match("69") and " (nice!)" or "")
		)

	elseif step == 1 then -- channels
		local channels = stats.channels

		self.state =
			channels == 0
				and
			"Watching the world go by"
				or (
			channels == 1
				and
			"Watching over 1 channel"
				or
			format("Watching over %d channels", channels) .. (tostring(channels):match("69") and " (nice!)" or "")
		)

	elseif step == 2 then -- lobbies
		local lobbies = stats.lobbies

		self.state =
			lobbies == 0
				and
			"Watching the world go by"
				or (
			lobbies == 1
				and
			"Watching over 1 lobby"
				or
			format("Watching over %d lobbies", lobbies) .. (tostring(lobbies):match("69") and " (nice!)" or "")
		)

	elseif step == 3 then -- guilds
		local guilds = #client.guilds

		self.state =
			guilds == 0
				and
			"Watching the world go by"
				or (
			guilds == 1
				and
			"Watching over 1 guild"
				or
			format("Watching over %d guilds", guilds) .. (tostring(guilds):match("69") and " (nice!)" or "")
		)
	end
	return self
end