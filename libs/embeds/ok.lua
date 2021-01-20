local locale = require "locale"

-- no embed data is saved, since this is non-interactive embed
embeds:new("ok", function (msg)
	return {
		title = locale.embedOK,
		color = 0x6157634,
		description = msg
	}
end)