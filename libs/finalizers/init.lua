error("what a surprise")

return setmetatable({
	register = require "./register.lua",
	unregister = require "./unregister.lua",
	template = require "./template.lua",
	target = require "./target.lua"
},{
	__call = function (self, message, ids, action)
		return (self[action] or self[action:match("^template")] or self[action:match("^target")])(message, ids, action)
	end
})