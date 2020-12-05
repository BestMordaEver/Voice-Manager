local config = require "config"
local locale = require "locale"

-- no embed data is saved, since this is non-interactive embed
return function (message, command)
	message:reply({embed = {
		title = "Help | " .. command:gsub("^.", string.upper, 1),	-- upper bold text
		color = config.embedColor,
		description = locale[command]..locale.links,
		footer = {text = locale.embedTip}
	}})
end