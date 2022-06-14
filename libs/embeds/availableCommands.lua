local locale = require "locale"

local guilds = require "storage".guilds
local channels = require "storage".channels

local chatCommands = {
	moderate = "mute, unmute, hide, show",
	manage = "rename, clear",
	mute = "mute, unmute",
	rename = "rename"
}

local roomCommands = {
	moderate = "mute, unmute, block, reserve, kick",
	manage = "rename, resize, bitrate",
	mute = "mute, unmute",
	rename = "rename",
	resize = "resize",
	bitrate = "bitrate"
}

return function (room)
	local parent = channels[room.id].parent or guilds[room.guild.id]
	local roomC, chatC = "",""

	for name, _ in pairs(parent.permissions.bits) do
		if chatCommands[name] and parent.permissions:has(name) and not chatC:match(chatCommands[name]) then
			chatC = chatC..chatCommands[name]..", "
		end
	end

	for name, _ in pairs(parent.permissions.bits) do
		if roomCommands[name] and parent.permissions:has(name) and not roomC:match(roomCommands[name]) then
			roomC = roomC..roomCommands[name]..", "
		end
	end

	chatC = chatC == "" and locale.none or chatC:sub(1,-3)
	roomC = roomC == "" and locale.none or roomC:sub(1,-3)

	return roomC, chatC
end