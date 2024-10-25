local locale = require "locale/runtime/localeHandler"
local client = require "client"
local embed = require "embeds/embed"

local channels = require "storage/channels"
local roomButtons = require "utils/components".roomButtons

local availableCommands = require "embeds/availableCommands"

local fuchsia = embed.colors.fuchsia

return embed("greeting", function (room, ephemeral)
	local channelData = channels[room.id]
	if not channelData then return end

	if not (channelData.parent.greeting or channelData.parent.companionLog) then return end

	local companion = client:getChannel(channelData.companion) or room

	local member = room.guild:getMember(channelData.host)
	local uname = member.user.name
	local nickname = member.nickname or uname

	local rt = {
		roomname = room.name,
		chatname = companion.name,
		nickname = nickname,
		name = uname,
		tag = member.user.tag,
		["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
		["name's"] = uname .. (uname:sub(-1,-1) == "s" and "'" or "'s"),
		commands = locale(member.user.locale, "roomCommands") .. availableCommands(room),
		buttons = ""
	}

	return {
	embeds = {{
		title = companion.name,
		color = fuchsia,
		description =
		(channelData.parent.greeting and channelData.parent.greeting:gsub("%%(.-)%%", rt) or "")
			..
		(channelData.parent.companionLog and locale(member.user.locale, "loggerWarning") or "")
	}},
	components = channelData.parent.greeting and channelData.parent.greeting:match("%%buttons%%") and roomButtons or nil,
	ephemeral = ephemeral}
end)