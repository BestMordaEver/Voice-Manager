local discordia = require "discordia"
local locale = require "locale"
local lobbies = require "storage/lobbies"

local client = discordia.storage.client
local permission = discordia.enums.permission
local actionParse = require "utils/actionParse"
local finalizer = require "finalizer"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids, target)
	if not ids then
		target = message.content:match('target%s*".-"%s*(.-)$') or message.content:match('target%s*(.-)$')
		
		ids = actionParse(message, message.content:match('"(.-)"'), "target", target)
		if not ids[1] then return ids end -- message for logger
		
		local targetCategory = client:getChannel(target)
		if not (targetCategory and targetCategory.createVoiceChannel) then
			if not message.guild then
				message:reply(locale.noID)
				return "Template by name in dm"
			end
			
			local categories = message.guild.categories:toArray(function (category) return category.name:lower() == target:lower() end)
			
			if not categories[1] then
				message:reply(lobbies[ids[1]].target and locale.lobbyTarget:format(client:getChannel(ids[1]).name, lobbies[ids[1]].target) or locale.noTarget)
				return "Sent channel target"
			end
			
			targetCategory = categories[1]
			target = targetCategory.id
		end
		
		if not targetCategory.guild:getMember(message.author):hasPermission(targetCategory, permission.manageChannels) then
			message:reply(locale.badUserPermission.." "..targetCategory.name)
			return "User doesn't have permission to manage the target"
		end
		
		if targetCategory and not targetCategory.guild.me:hasPermission(targetCategory, permission.manageChannels) then
			message:reply(locale.badBotPermission.." "..targetCategory.name)
			return "Bot doesn't have permission to manage the target"
		end
	end
	
	target, ids = finalizer.target(message, ids, target)
	message:reply(target)
	return (#ids == 0 and "Successfully applied target to all" or ("Couldn't apply target to "..table.concat(ids, " ")))
end