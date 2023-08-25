local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local green = embedHandler.colors.green

return embedHandler("ok", function (msg, ephemeral)
	return {embeds = {{
		title = locale.embedOK,
		color = green,
		description = msg
	}}, ephemeral = ephemeral}
end)