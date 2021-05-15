local locale = require "locale"
local embeds = require "embeds/embeds"
local colors = embeds.colors

-- no embed data is saved, since this is non-interactive embed
embeds:new("warning", function (msg)
	return {
		title = locale.embedWarning,
		color = colors.yellow,
		description = msg
	}
end)