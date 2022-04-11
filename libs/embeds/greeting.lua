local locale = require "locale"
local client = require "client"
local embeds = require "embeds"

local channels = require "storage".channels

local availableCommands = require "embeds/availableCommands"

local fuchsia = embeds.colors.fuchsia

return embeds("greeting", function (room, ephemeral)
	local channelData = channels[room.id]
	if not channelData then return end

	local companion = client:getChannel(channelData.companion)
	if not companion then return end

	local roomC, chatC = availableCommands(room)

	local member = room.guild:getMember(channelData.host)
	local uname = member.user.name
	local nickname = member.nickname or uname

	local rt = {
		roomname = room.name,
		chatname = companion and companion.name or nil,
		nickname = nickname,
		name = uname,
		tag = member.user.tag,
		["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
		["name's"] = uname .. (uname:sub(-1,-1) == "s" and "'" or "'s"),
		commands = locale.roomCommands .. roomC .."\n" .. locale.chatCommands .. chatC,
		roomcommands = roomC,
		chatcommands = chatC
	}

	return {embeds = {{
		title = companion.name,
		color = fuchsia,
		description = (channelData.parent.greeting or ""):gsub("%%(.-)%%", rt) .. (channelData.parent.companionLog and locale.loggerWarning or "")
	}}, ephemeral = ephemeral}
end)