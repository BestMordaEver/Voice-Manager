local discordia = require "discordia"
local locale = require "../locale.lua"

local lobbies = require "../lobbies.lua"

local channelType, permission = discordia.enums.channelType, discordia.enums.permission
local client = discordia.storage.client

return function (message, ids)
	local badUser, badBot, badChannel, redundant = {}, {}, {}, {}
	
	for i,_ in ipairs(ids) do repeat
		local channel = client:getChannel(ids[i])
		if channel then
			if channel.type == channelType.voice and channel.guild:getMember(message.author) then
				if not lobbies[channel.id] then
					if channel.guild:getMember(message.author) and channel.guild:getMember(message.author):hasPermission(channel, permission.manageChannels) then
						if channel.guild.me:hasPermission(channel.category, permission.manageChannels) then
							break
						else
							table.insert(badBot, table.remove(ids, i))
						end
					else
						table.insert(badUser, table.remove(ids, i))
					end
				else
					table.insert(redundant, table.remove(ids, i))
				end
			else
				table.insert(badChannel, table.remove(ids, i))
			end
		else break end
	until not ids[i] end

	local msg = ""
	if #ids > 0 then
		msg = string.format(#ids == 1 and locale.registeredOne or locale.registeredMany,#ids).."\n"
		for _, channelID in ipairs(ids) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
			lobbies:add(channelID)
		end
	end
	
	if #badChannel > 0 then
		msg = msg..(#badChannel == 1 and locale.badChannel or locale.badChannels).."\n"
		for _, channelID in ipairs(badChannel) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
		end
	end
	
	if #redundant > 0 then
		msg = msg..(#redundant == 1 and locale.redundantRegister or locale.redundantRegisters).."\n"
		for _, channelID in ipairs(redundant) do
			local channel = client:getChannel(channelID)
			msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
			table.insert(badChannel, channelID)
		end
	end

	if #badBot > 0 then
		msg = msg..(#badBot == 1 and locale.badBotPermission or locale.badBotPermissions).."\n"
		for _, channelID in ipairs(badBot) do
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