local config = require "config"
local locale = require "locale"

-- no embed data is saved, since this is non-interactive embed
return function (message, guild)
	message:reply({embed = {
		title = "Server info | " .. guild.name,
		color = config.embedColor,
		description = "sexy goblin???",
		footer = {text = command ~= "help" and locale.embedTip or nil}
	}})
end