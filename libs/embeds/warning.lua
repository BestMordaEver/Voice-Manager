local locale = require "locale"
local embeds = require "embeds"

local yellow = embeds.colors.yellow

return embeds("warning", function (msg, ephemeral)
	return {embeds = {{
		title = locale.embedWarning,
		color = yellow,
		description = msg
	}}, ephemeral = ephemeral}
end)