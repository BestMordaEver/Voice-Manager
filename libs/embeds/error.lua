local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local red = embedHandler.colors.red

return embedHandler("error", function (ephemeral)
	return {embeds = {{
		title = locale.embedError,
		color = red,
		description = locale.error:format(locale.errorReaction[math.random(1, #locale.errorReaction)])
	}}, ephemeral = ephemeral}
end)