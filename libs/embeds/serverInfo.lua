local config = require "config"
local locale = require "locale"

-- no embed data is saved, since this is non-interactive embed
return function (message, guild)
	message:reply({embed = {
		title = "Server info | " .. guild.name,
		color = config.embedColor,
		description = "**• Prefix:** lr!\n**• Permissions:** manage, name\n**• Lobbies:** 2\n**• Active users:** 69\n**• Channels:** 20\n**• Limit:** 500"
	}})
end