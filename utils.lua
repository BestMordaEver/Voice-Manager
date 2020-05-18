local discordia = require "discordia"
local mutexes = {}

return {
	truePositionSorting = function (a, b)
		return (not a.category and b.category) or
			(a.category and b.category and a.category.position < b.category.position) or
			(a.category == b.category and a.position < b.position)
	end,
	
	storageInteractionEvent = function (statement, ...)
		if not mutexes[statement] then
			mutexes[statement] = discordia.Mutex()
		end
		mutexes[statement]:lock()
		statement:reset():bind(...):step()
		mutexes[statement]:unlock()
	end
}