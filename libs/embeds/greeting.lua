local locale = require "locale"
local client = require "client"
local embeds = require "embeds/embeds"
local channels = require "storage/channels"
local guilds = require "storage/guilds"
local availableCommands = require "funcs/availableCommands"

-- no embed data is saved, since this is non-interactive embed
embeds:new("greeting", function (room)
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
		commands = string.format("%s%s\n%s%s", locale.roomCommands, roomC, locale.chatCommands, chatC),
		roomcommands = roomC,
		chatcommands = chatC
	}
	
	return {
		title = companion.name,
		color = 6561661,
		description = channelData.parent.greeting:gsub("%%(.-)%%", rt)
	}
end)