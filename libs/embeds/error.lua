local locale = require "locale"
local embeds = require "embeds/embeds"
local colors = embeds.colors

-- no embed data is saved, since this is non-interactive embed
embeds:new("error", function ()
	return {
		title = locale.embedError,
		color = colors.red,
		description = locale.error:format(locale.errorReaction[math.random(1, #locale.errorReaction)])
	}
end)