local discordia = require "discordia"
local mutexes = {}

return {
	-- returns channels in the same order they are presented in the app
	-- https://imgur.com/a/hRWM73c
	truePositionSorting = function (a, b)
		return (not a.category and b.category) or
			(a.category and b.category and a.category.position < b.category.position) or
			(a.category == b.category and a.position < b.position)
	end,
	
	-- any interaction with database comes through here
	-- it ensures that no statement is used by two threads at the same time 
	storageInteractionEvent = function (statement, ...)
		if not mutexes[statement] then
			mutexes[statement] = discordia.Mutex()
		end
		mutexes[statement]:lock()
		local ok, msg = pcall(function (...) statement:reset():bind(...):step() end, ...)
		mutexes[statement]:unlock()
		if not ok then error(msg) end
	end
}