local locale = require "locale"

-- no embed data is saved, since this is non-interactive embed
embeds:new("warning", function (msg)
	return {
		title = locale.embedWarning,
		color = 0xffe100,
		description = msg
	}
end)