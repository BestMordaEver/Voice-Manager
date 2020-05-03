local client = require "discordia".storage.client
local guilds = require "./guilds.lua"
local lobbies = require "./lobbies.lua"

return {
	truePositionSorting = function (a, b)
		return (not a.category and b.category) or
			(a.category and b.category and a.category.position < b.category.position) or
			(a.category == b.category and a.position < b.position)
	end,
	
	getTemplate = function (channel)
		return (lobbies[channel.id].template or guilds[channel.guild.id].template or "%nickname's% channel")
	end,
}