local locale = require "locale"
local embeds = require "embeds"

local red = embeds.colors.red

return embeds("error", function (ephemeral)
	return {embeds = {{
		title = locale.embedError,
		color = red,
		description = locale.error:format(locale.errorReaction[math.random(1, #locale.errorReaction)])
	}}, ephemeral = ephemeral}
end)