local handler = {
	["en-US"] = require "locale/runtime/en-US",
}

return function (locale, line, ...)
	if not handler[locale] or not handler[locale][line] then locale = "en-US" end
	assert(handler[locale][line], "there is no line "..line)
	if ... then
		assert(type(locale[line]) == "string", "this line does not support editable parameters")
		return locale[line]:format(...)
	else
		return locale[line]
	end
end