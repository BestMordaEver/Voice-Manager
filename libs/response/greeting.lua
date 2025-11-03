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
		commands = localeHandler(locale, "roomCommands") .. availableCommands(room),
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
					label = localeHandler(locale, "roomButtonsShow"),
					custom_id = "room_widget_show_both",
					emoji = {name = "👁"}
				},{
					type = componentType.button,
					style = buttonStyle.success,
					label = localeHandler(locale, "roomButtonsUnlock"),
					custom_id = "room_widget_unlock",
					emoji = {name = "🔓"}
				},{
					type = componentType.button,
					style = buttonStyle.success,
					label = localeHandler(locale, "roomButtonsUnmuteV"),
					custom_id = "room_widget_unmute_voice",
					emoji = {name = "🔉"}
				},{
					type = componentType.button,
					style = buttonStyle.success,
					label = localeHandler(locale, "roomButtonsUnmuteT"),
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
					label = localeHandler(locale, "roomButtonsHide"),
					custom_id = "room_widget_hide_both",
					emoji = {name = "🥷"}
				},{
					type = componentType.button,
					style = buttonStyle.secondary,
					label = localeHandler(locale, "roomButtonsLock"),
					custom_id = "room_widget_lock",
					emoji = {name = "🔒"}
				},{
					type = componentType.button,
					style = buttonStyle.secondary,
					label = localeHandler(locale, "roomButtonsMuteV"),
					custom_id = "room_widget_mute_voice",
					emoji = {name = "🔇"}
				},{
					type = componentType.button,
					style = buttonStyle.secondary,
					label = localeHandler(locale, "roomButtonsMuteT"),
					custom_id = "room_widget_mute_text",
					emoji = {name = "📵"}
				}
			}
		} or nil,
	}
end)

return greeting