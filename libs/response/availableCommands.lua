local guilds = require "storage/guilds"
local channels = require "storage/channels"

local commands = {
	moderate = "mute, block, kick, hide, lock, password",
	manage = "rename, resize, bitrate",
	rename = "rename",
	resize = "resize",
	bitrate = "bitrate",
	kick = "kick",
	mute = "mute",
	hide = "hide",
	lock = "lock",
	password = "password"
}

return function (room)
	local parent = channels[room.id].parent or guilds[room.guild.id]
	local commandsStrings = {}

	for permission, commandLine in pairs(commands) do
		if parent.permissions:has(permission) then
			table.insert(commandsStrings, commandLine)
		end
	end

	return table.concat(commandsStrings,", ")
end