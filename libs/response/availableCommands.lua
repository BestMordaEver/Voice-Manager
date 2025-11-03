local client = require "client"

local guilds = require "storage/guilds"
local channels = require "storage/channels"

local localeHandler = require "locale/localeHandler"

local commands = {
	moderate = {
		"mute",
		"kick",
		"hide",
		"lock",
		"password"
	},
	manage = {
		"rename",
		"resize",
		"bitrate"
	},
	rename = {"rename"},
	resize = {"resize"},
	bitrate = {"bitrate"},
	kick = {"kick"},
	mute = {"mute"},
	hide = {"hide"},
	lock = {"lock"},
	password = {"password"},
}

return function (room)
	local parent = channels[room.id].parent or guilds[room.guild.id]
	local locale = client:getUser(channels[room.id].host).locale
	local permitted, commandsStrings = {}, {}

	for permission, commandNames in pairs(commands) do
		if parent.permissions:has(permission) then
			for _, commandName in pairs(commandNames) do
				if not permitted[commandName] then
					permitted[commandName] = true
					table.insert(commandsStrings, localeHandler(locale, commandName))
				end
			end
		end
	end

	return table.concat(commandsStrings," ")
end