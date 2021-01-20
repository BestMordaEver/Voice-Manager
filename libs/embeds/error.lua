local locale = require "locale"

-- no embed data is saved, since this is non-interactive embed
embeds:new("warning", function ()
	return {
		title = locale.embedError,
		color = 0xff0000,
		description = locale.error:format(locale.errorReaction[math.random(1, #locale.errorReaction)])
	}
end)