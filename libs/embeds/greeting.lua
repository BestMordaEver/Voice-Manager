local locale = require "locale"
local client = require "client"
local embedHandler = require "handlers/embedHandler"

local channels = require "handlers/storageHandler".channels

local availableCommands = require "embeds/availableCommands"

local enums = require "discordia".enums
local buttonStyle = enums.buttonStyle
local componentType = enums.componentType
local fuchsia = embedHandler.colors.fuchsia

local selects = {
	{
		type = componentType.row,
		components = {
			{
				type = componentType.button,
				style = buttonStyle.success,
				label = "Show",
				custom_id = "room_widget_show_both",
				emoji = {name = "👁"}
			},{
				type = componentType.button,
				style = buttonStyle.success,
				label = "Unlock",
				custom_id = "room_widget_unlock",
				emoji = {name = "🔓"}
			},{
				type = componentType.button,
				style = buttonStyle.success,
				label = "Unmute voice",
				custom_id = "room_widget_unmute_voice",
				emoji = {name = "🔉"}
			},{
				type = componentType.button,
				style = buttonStyle.success,
				label = "Unmute text",
				custom_id = "room_widget_unmute_text",
				emoji = {name = "🖊"}
			}
		}
	},{
		type = componentType.row,
		components = {
			{
				type = componentType.button,
				style = buttonStyle.secondary,
				label = "Hide",
				custom_id = "room_widget_hide_both",
				emoji = {name = "🥷"}
			},{
				type = componentType.button,
				style = buttonStyle.secondary,
				label = "Lock",
				custom_id = "room_widget_lock",
				emoji = {name = "🔒"}
			},{
				type = componentType.button,
				style = buttonStyle.secondary,
				label = "Mute voice",
				custom_id = "room_widget_mute_voice",
				emoji = {name = "🔇"}
			},{
				type = componentType.button,
				style = buttonStyle.secondary,
				label = "Mute text",
				custom_id = "room_widget_mute_text",
				emoji = {name = "📵"}
			}
		}
	}
}

return embedHandler("greeting", function (room, ephemeral)
	local channelData = channels[room.id]
	if not channelData then return end

	if not channelData.parent.greeting then return end

	local companion = client:getChannel(channelData.companion)
	if not companion then return end

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
		commands = locale.roomCommands .. availableCommands(room),
		buttons = ""
	}

	return {
	embeds = {{
		title = companion.name,
		color = fuchsia,
		description = channelData.parent.greeting:gsub("%%(.-)%%", rt) .. (channelData.parent.companionLog and locale.loggerWarning or "")
	}},
	components = channelData.parent.greeting:match("%%buttons%%") and selects or nil,
	ephemeral = ephemeral}
end)