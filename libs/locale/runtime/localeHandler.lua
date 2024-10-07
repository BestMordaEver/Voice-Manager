local handler = {
	["en-US"] = require "locale/runtime/en-US",
}

---@param locale table
---@param line textLine
---@param ... string
---@return string | table
return function (locale, line, ...)
	locale = handler[locale]
	if not locale or not locale[line] then locale = handler["en-US"] end
	assert(locale[line], "there is no line "..line)
	if ... then
		assert(type(locale[line]) == "string", "this line does not support editable parameters")
		return locale[line]:format(...)
	else
		return locale[line]
	end
end