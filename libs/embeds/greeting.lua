local locale = require "locale"
local client = require "client"
local embeds = require "embeds"

local channels = require "storage".channels

local availableCommands = require "embeds/availableCommands"

local enums = require "discordia".enums
local componentType, buttonStyle = enums.componentType, enums.buttonStyle
local fuchsia = embeds.colors.fuchsia

local roombuttons = {
	open = {
		type = componentType.button,
		label = "Public",
		emoji = {name = "🔊"},
		custom_id = "room_widget_lock",
		style = buttonStyle.primary
	},
	lock = {
		type = componentType.button,
		label = "Locked",
		emoji = {name = "🔒"},
		custom_id = "room_widget_hide",
		style = buttonStyle.primary
	},
	hide = {
		type = componentType.button,
		label = "Invisible",
		emoji = {name = "⛔"},
		custom_id = "room_widget_open",
		style = buttonStyle.primary
	}
}

local chatbuttons = {
	open = {
		type = componentType.button,
		label = "Public",
		emoji = {name = "✒"},
		custom_id = "chat_widget_lock",
		style = buttonStyle.primary
	},
	lock = {
		type = componentType.button,
		label = "Visible",
		emoji = {name = "📄"},
		custom_id = "chat_widget_hide",
		style = buttonStyle.primary
	},
	hide = {
		type = componentType.button,
		label = "Invisible",
		emoji = {name = "🥷"},
		custom_id = "chat_widget_open",
		style = buttonStyle.primary
	}
}

return embeds("greeting", function (room, roombutton, chatbutton, ephemeral)
	local channelData = channels[room.id]
	if not channelData then return end

	local companion = client:getChannel(channelData.companion)
	if not companion then return end

	if not channelData.parent.greeting then return end

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
		chatcommands = chatC,
		buttons = ""
	}

	return {embeds = {{
		title = companion.name,
		color = fuchsia,
		description = channelData.parent.greeting:gsub("%%(.-)%%", rt) .. (channelData.parent.companionLog and locale.loggerWarning or "")
	}},
	components = channelData.parent.greeting:match("%%buttons%%") and {{
		type = componentType.row,
		components = {roombuttons[roombutton or "open"], chatbuttons[chatbutton or "hide"]}
	}} or nil, ephemeral = ephemeral}
end)
