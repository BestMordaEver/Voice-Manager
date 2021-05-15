local locale = require "locale"
local embeds = require "embeds/embeds"
local colors = embeds.colors

-- no embed data is saved, since this is non-interactive embed
embeds:new("ok", function (msg)
	return {
		title = locale.embedOK,
		color = colors.green,
		description = msg
	}
end)