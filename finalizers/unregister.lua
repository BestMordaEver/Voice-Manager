local discordia = require "discordia"
local locale = require "../locale.lua"

local guilds = require "../guilds.lua"
local lobbies = require "../lobbies.lua"

local channelType, permission = discordia.enums.channelType, discordia.enums.permission
local client = discordia.storage.client

return function (message, ids)
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

	local msg = ""
	if #ids > 0 then
		msg = string.format(#ids == 1 and locale.unregisteredOne or locale.unregisteredMany, #ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
			guilds[channel.guild.id].lobbies:remove(channelID)
			lobbies:remove(channelID)
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
		msg = msg..(#notLobby == 1 and locale.notLobby or locale.notLobbies).."\n"
		for _, channelID in ipairs(notLobby) do
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