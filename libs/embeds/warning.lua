local locale = require "locale"
local embeds = require "embeds/embeds"

-- no embed data is saved, since this is non-interactive embed
embeds:new("warning", function (msg)
	return {
		title = locale.embedWarning,
		color = 0xffe100,
		description = msg
	}
end)