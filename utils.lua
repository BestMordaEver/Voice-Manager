local client = require "discordia".storage.client
local guilds = require "./guilds.lua"
local locale = require "./locale.lua"

return {
	truePositionSorting = function (a, b)
		return (not a.category and b.category) or
			(a.category and b.category and a.category.position < b.category.position) or
			(a.category == b.category and a.position < b.position)
	end,

	getLocale = function (guild)	
		return (guild and guilds[guild.id].locale or locale.english)
	end
}