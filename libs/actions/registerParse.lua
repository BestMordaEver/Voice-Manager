local discordia = require "discordia"
local locale = require "locale"
local lobbies = require "storage/lobbies"
local embeds = require "embeds"

local client = discordia.storage.client
local permission = discordia.enums.permission
local truePositionSorting = require "utils/truePositionSorting"
local getIDs = require "actions/getIDs"

return function (message, command) -- register unregister action pre-processing
	local ids, nameDuplicates = getIDs(message.guild, message.content:match(command.."%s+(.-)$"))
	if not ids[1] then
		if not message.guild then
			message:reply(locale.noID)
			return "Empty input"
		elseif not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
			message:reply(locale.gimmeReaction)
			return "Empty input, can't do embed"
		end
		
		local ids = {}
		for _,channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel)
			return (command == "register") == not lobbies[channel.id] and		-- embeds never offer redundant channels
				message.guild.me:hasPermission(channel.category, permission.manageChannels) and
				message.member:hasPermission(channel, permission.manageChannels)	-- non-embed related permission checks are in actionFinalizer
		end), truePositionSorting)) do
			table.insert(ids, channel.id)
		end
		
		local newMessage = embeds:send(message, command, ids)
		if newMessage then
			return "Empty input, sent embed ".. newMessage.id
		else
			return "Couldn't send an embed"
		end
	end
	
	if #ids == 0 then
		message:reply(locale.badInput)
		return "Didn't find the channel"
	elseif nameDuplicates then
		local redundant, count = {}, #ids
		
		for i, _ in ipairs(ids) do repeat	-- clear out invalid channels
			local channel = client:getChannel(ids[i])
			if not ((command == "register") == not lobbies[channel.id] and
				message.guild.me:hasPermission(channel.category, permission.manageChannels) and
				message.member:hasPermission(channel, permission.manageChannels)) then
				
				table.insert(redundant, table.remove(ids, i))
			else
				break
			end
		until not ids[i] end
		
		if #ids == 1 then return ids end -- if only one still valid - proceed
		if #redundant == count then return redundant end -- if all are invalid - proceed for finalizer output
		
		if not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
			message:reply(locale.ambiguousID.."\n"..locale.gimmeReaction)
			return "Ambiguous input, can't do embed"
		end
		
		local newMessage = embeds:send(message, command, ids)
		if newMessage then 
			newMessage:setContent(locale.ambiguousID)
			return "Ambiguous input, sent embed "..newMessage.id
		else
			return "Couldn't send an embed"
		end
	else
		return ids
	end
end
