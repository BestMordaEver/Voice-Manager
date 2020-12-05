local reactions = require "libs/embeds/embeds".reactions
local locale = require "locale"

-- no embed data is saved, since this is non-interactive embed
return function (message, command)
	message:reply({embed = {
		title = "Help | " .. command:gsub("^.", string.upper, 1),	-- upper bold text
		color = 6561661,
		description = locale[command]..locale.links,
		footer = {text = command ~= "help" and locale.embedTip or nil}
	}})
end