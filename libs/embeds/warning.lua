local locale = require "locale"
local embeds = require "embeds"

local yellow = embeds.colors.yellow

return embeds("warning", function (msg)
	return {embeds = {{
		title = locale.embedWarning,
		color = yellow,
		description = msg
	}}}
end)