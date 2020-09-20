local discordia = require "discordia"
local locale = require "locale"
local embeds = require "embeds"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local truePositionSorting = require "utils/truePositionSorting"
local permission = discordia.enums.permission

return function (message, command) -- template target action pre-processing
	local reset, scope, argument = message.content:match('^.-'..command..'%s*(.-)%s*"(.-)"%s*(.-)$')
	
	if scope then
		local ids, duplicateNames
		if command == "template" and scope == "global" and message.guild then 
			ids = {[1] = message.guild.id}
		else
			ids, duplicateNames = getIDs(message.guild, scope)
		end
		
		if #ids > 1 and duplicateNames then
			message:reply(locale.ambiguousID)
			return "Ambiguous input"
		end
		
		if reset == "" and argument == "" then
			if client:getGuild(ids[1]) then
				message:reply(guilds[ids[1]].template and locale.globalTemplate:format(guilds[ids[1]].template) or locale.defaultTemplate)
				return "Sent global template"
			elseif client:getChannel(ids[1]) then
				message:reply(command == "template" and
					(lobbies[ids[1]].template and locale.lobbyTemplate:format(client:getChannel(ids[1]).name, lobbies[ids[1]].template) or locale.noTemplate)
					or
					(lobbies[ids[1]].target and locale.lobbyTarget:format(client:getChannel(ids[1]).name, lobbies[ids[1]].target) or locale.noTarget))
				return "Sent channel "..command
			else
				message:reply(locale.badInput)
				return "Didn't find the channel"
			end
		elseif #ids == 0 then
			message:reply(locale.badInput)
			return "Didn't find the channel"
		elseif reset == "reset" then
			return ids
		elseif argument ~= "" then
			if command == "target" then
				local parent = client:getChannel(argument)
				
				if not (parent and parent.createVoiceChannel) then
					if not message.guild then
						message:reply(locale.noID)
						return "Template by name in dm"
					end
					
					local categories = message.guild.categories:toArray(function (category) return category.name:lower() == argument:lower() end)
					if not categories[1] then
						message:reply(locale.badInput)
						return "Didn't find the channel"
					end
					parent = categories[1]
					argument = parent.id
				end
				
				if not parent.guild:getMember(message.author):hasPermission(parent, permission.manageChannels) then
					message:reply(locale.badUserPermission.."\nCategory `"..parent.name.."`")
					return "User doesn't have permission to manage the category"
				end
			end
			
			return ids, argument
		end
	else
		argument = message.content:match("^.-"..command.."%s*(.-)%s*$")
		if message.guild then
			if command == "template" and argument == "" then
				message:reply(guilds[message.guild.id].template and locale.globalTemplate:format(guilds[message.guild.id].template) or locale.defaultTemplate)
				return "Sent global template"
			else
				if not message.guild.me:getPermissions(message.channel):has(permission.manageMessages, permission.addReactions) then
					message:reply(locale.gimmeReaction)
					return "Empty template, can't do embed"
				end
				
				local ids = {}
				for _, channel in ipairs(table.sorted(message.guild.voiceChannels:toArray(function (channel) return lobbies[channel.id] end), truePositionSorting)) do
					table.insert(ids, channel.id)
				end
				if argument == "reset" then argument = "" end
				
				local newMessage = embeds:send(message, command..argument, ids)
				if newMessage then
					return "Empty "..command..", sent embed ".. newMessage.id
				else
					return "Couldn't send an embed"
				end
			end
		else
			message:reply(locale.noID)
			return "Empty "..command.." in dm"
		end
	end
end
