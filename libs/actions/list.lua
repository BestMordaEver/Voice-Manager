local discordia = require "discordia"
local locale = require "locale"
local lobbies = require "storage/lobbies"
local truePositionSorting = require "utils/truePositionSorting"

local client = discordia.storage.client

return function (message)
	local guild = client:getGuild(message.content:match("list%s*(%d+)")) or message.guild
	if not guild then
		message:reply(locale.badServer)
		return "Didn't find the guild"
	elseif not guild:getMember(message.author) then
		message:reply(locale.notMember)
		return "Not a member"
	end
	
	local lobbies = guild.voiceChannels:toArray(function (channel) return lobbies[channel.id] end)
	table.sort(lobbies, truePositionSorting)
	
	local msg = (#lobbies == 0 and locale.noLobbies or locale.someLobbies) .. "\n"
	for _,channel in ipairs(lobbies) do
		msg = msg..string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name).."\n"
	end
	
	message:reply(msg)
	return "Sent lobby list"
end