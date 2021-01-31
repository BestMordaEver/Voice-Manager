local locale = require "locale"
local embeds = require "embeds/embeds"

-- no embed data is saved, since this is non-interactive embed
embeds:new("ok", function (msg)
	return {
		title = locale.embedOK,
		color = 0x08d43f,
		description = msg
	}
end)