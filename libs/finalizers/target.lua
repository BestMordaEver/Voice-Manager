local discordia = require "discordia"
local locale = require "locale"

local lobbies = require "storage/lobbies"

local channelType, permission = discordia.enums.channelType, discordia.enums.permission
local client = discordia.storage.client

return function (message, ids, action)
	local badUser, badChannel, notLobby = {}, {}, {}
	
	for i,_ in ipairs(ids) do repeat
		local channel = client:getChannel(ids[i])
		if channel then
			if channel.type == channelType.voice and channel.guild:getMember(message.author) then
				if lobbies[channel.id] then 
					if channel.guild:getMember(message.author):hasPermission(channel, permission.manageChannels) then
						break
					else
						table.insert(badUser, table.remove(ids, i))
					end
				else
					table.insert(notLobby, table.remove(ids, i))
				end
			else
				table.insert(badChannel, table.remove(ids, i))
			end
		else break end
	until not ids[i] end

	local msg, target = "", action:match("^target(.+)$")
	if #ids > 0 then
		msg = string.format(target and locale.newTarget or locale.resetTarget, target).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
			lobbies:updateTarget(channelID, target)
		end
	end
	
	if #badChannel > 0 then
		msg = msg..(#badChannel == 1 and locale.badChannel or locale.badChannels).."\n"
		for _, channelID in ipairs(badChannel) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
		end
	end
	
	if #notLobby > 0 then
		msg = msg..(#redundant == 1 and locale.notLobby or locale.notLobbies).."\n"
		for _, channelID in ipairs(redundant) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
			table.insert(badChannel, channelID)
		end
	end

	if #badUser > 0 then
		msg = msg..(#badUser == 1 and locale.badUserPermission or locale.badUserPermissions).."\n"
		for _, channelID in ipairs(badUser) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
			table.insert(badChannel, channelID)
		end
	end
	
	return msg, badChannel
end