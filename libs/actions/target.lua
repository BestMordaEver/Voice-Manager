local discordia = require "discordia"
local locale = require "locale"

local client = discordia.storage.client
local permission = discordia.enums.permission
local complexParse = require "actions/complexParse"
local actionFinalizer = require "finalizers/target"

-- this function is also used by embeds, they will supply ids and target
return function (message, ids, target)
	if not ids then
		ids, target = complexParse(message, "target")
		if not ids[1] then return ids end -- message for logger
	end
	
	local targetCategory = client:getChannel(target)
	if target and not targetCategory then
		local ids = {}
		if message.guild then
			for _, channel in pairs(message.guild.categories) do
				if channel.name:lower() == line then
					table.insert(ids, channel.id)
				end
			end
		end
		if not ids[1] then
			message:reply(locale.badCategory)
			return "Couldn't find target"
		end
		targetCategory = ids[1]
	end
	
	if targetCategory and not targetCategory.guild.me:hasPermission(targetCategory, permission.manageChannels) then
		message:reply(locale.badBotPermission.." "..targetCategory.name)
		return "Bad permissions for target"
	end
	
	target, ids = actionFinalizer(message, ids, "target"..(target or ""))
	message:reply(target)
	return (#ids == 0 and "Successfully applied target to all" or ("Couldn't apply target to "..table.concat(ids, " ")))
end