local locale = require "locale"
local client = require "client"
local embeds = require "embeds"

local channels = require "storage".channels

local availableCommands = require "embeds/availableCommands"

local enums = require "discordia".enums
local componentType, buttonStyle = enums.componentType, enums.buttonStyle
local fuchsia = embeds.colors.fuchsia

local selects = {
	{
		type = componentType.row,
		components = {{
			type = componentType.select,
			custom_id = "room_widget",
			options = {
				{
					label = "Public",
					value = "open",
					description = "Anybody can enter the room",
					emoji = {name = "🔊"},
					default = true
				},{
					label = "Locked",
					value = "lock",
					description = "Only people you invite can enter the room",
					emoji = {name = "🔒"}
				},{
					label = "Invisible",
					value = "hide",
					description = "Only people you invite can see the room",
					emoji = {name = "⛔"}
				}
			}
		}}
	},{
		type = componentType.row,
		components = {{
			type = componentType.select,
			custom_id = "chat_widget",
			options = {
				{
					label = "Public",
					value = "open",
					description = "Anybody can write in your chat",
					emoji = {name = "✒"}
				},{
					label = "Visible",
					value = "lock",
					description = "Everybody can see the chat, but only room members can write",
					emoji = {name = "📄"}
				},{
					label = "Invisible",
					value = "hide",
					description = "Only room members can see the chat",
					emoji = {name = "🥷"},
					default = true
				}
			}
		}}
	}
}

return embeds("greeting", function (room, ephemeral)
	local channelData = channels[room.id]
	if not channelData then return end

	if not channelData.parent.greeting then return end

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
		chatcommands = chatC,
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