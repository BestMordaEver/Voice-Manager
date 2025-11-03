local client = require "client"
local localeHandler = require "locale/localeHandler"

local channels = require "storage/channels"

local availableCommands = require "response/availableCommands"

local enums = require "discordia".enums
local buttonStyle = enums.buttonStyle
local componentType = enums.componentType
local response = require "response/response"

---@overload fun(ephemeral : boolean, locale : localeName, room : GuildVoiceChannel) : table
local greeting = response("greeting", response.colors.fuchsia, function (locale, room)
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
		commands = localeHandler(member.user.locale, "roomCommands") .. availableCommands(room),
		buttons = ""
	}

	return {
		{
			type = componentType.textDisplay,
			content = "## "..companion.name
		},
		{
			type = componentType.textDisplay,
			content =
				(channelData.parent.greeting and channelData.parent.greeting:gsub("%%(.-)%%", rt) or "")
					..
				(channelData.parent.companionLog and localeHandler(member.user.locale, "loggerWarning") or "")

		},
		channelData.parent.greeting and channelData.parent.greeting:match("%%buttons%%") and {
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
		} or nil,
		channelData.parent.greeting and channelData.parent.greeting:match("%%buttons%%") and {
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
		} or nil,
	}
end)

return greeting