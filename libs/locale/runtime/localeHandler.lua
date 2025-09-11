---@overload fun(locale : localeName, line : textLine, ... : string) : string| string[]
local handler = setmetatable({
	["en-US"] = require "locale/runtime/en-US",
}, {
	__call = function (self, locale, line, ...)
	locale = self[locale]
	if not locale or not locale[line] then locale = self["en-US"] end
	assert(locale[line], "there is no line "..line)
	if ... then
		assert(type(locale[line]) == "string", "this line does not support editable parameters")
		return locale[line]:format(...)
	else
		return locale[line]
	end
end})

return handler