local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local yellow = embedHandler.colors.yellow

return embedHandler("warning", function (msg, ephemeral)
	return {embeds = {{
		title = locale.embedWarning,
		color = yellow,
		description = msg
	}}, ephemeral = ephemeral}
end)