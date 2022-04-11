local locale = require "locale"
local embeds = require "embeds"

local green = embeds.colors.green

return embeds("ok", function (msg, ephemeral)
	return {embeds = {{
		title = locale.embedOK,
		color = green,
		description = msg
	}}, ephemeral = ephemeral}
end)