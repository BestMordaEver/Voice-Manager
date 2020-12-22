local discordia = require "discordia"
local locale = require "locale"
local lobbies = require "storage/lobbies"

local client = discordia.storage.client
local permission = discordia.enums.permission
local channelType = discordia.enums.channelType
local commandParse = require "commands/commandParse"
local commandFinalize = require "commands/commandFinalize"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids, target)
	if not ids then
		target = message.content:match('companion%s*".-"%s*(.-)$') or message.content:match('companion%s*(.-)$')
		
		local potentialTarget = client:getChannel(target)
		if potentialTarget and potentialTarget.type ~= channelType.category then
			potentialTarget = nil
		elseif not potentialTarget then
			if not message.guild then
				message:reply(locale.noID)
				return "Companion by name in dm"
			end
			
			local categories = message.guild.categories:toArray("position", function (category) return category.name:lower() == target:lower() end)
			
			potentialTarget = categories[1]
			target = potentialTarget and potentialTarget.id or ""
		end
		
		if potentialTarget then
			if not potentialTarget.guild:getMember(message.author):hasPermission(potentialTarget, permission.manageChannels) then
				message:reply(locale.badUserPermission.." "..potentialTarget.name)
				return "User doesn't have permission to manage the companion target"
			end
			
			if not potentialTarget.guild.me:hasPermission(potentialTarget, permission.manageChannels) then
				message:reply(locale.badBotPermission.." "..potentialTarget.name)
				return "Bot doesn't have permission to manage the companion target"
			end
		end
		
		if target ~= "" and not potentialTarget then
			message:reply(locale.badCompanion)
			return "No companion category provided"
		end
		
		ids = commandParse(message, message.content:match('"(.-)"'), "companion", target)
		if not ids[1] then return ids end -- message for logger
	end
	
	return commandFinalize.companion(message, ids, target)
end