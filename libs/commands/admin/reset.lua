local commandParse = require "commands/commandParse"
local commandFinalize = require "commands/commandFinalize"

-- this function is NOT used by embeds, they will call corresponding functions with nil value
return function (message)
	
	local command, context = message.content:match('reset%s*(%a*)%s*"(.-)"')
	if not command then
		command, context = message.content:match("reset%s*(%a*)%s*(.-)$")
	end
	
	if command == "register" then
		command = "unregister"
	elseif command == "unregister" then
		command = "register"
	elseif command == "limit" then
		if context == "" then
			context = message.guild
		else
			context = client:getGuild(context)
		end

		commandFinalize.limit(message, context, 500)
	elseif command == "prefix" then
		if context == "" then
			context = message.guild
		else
			context = client:getGuild(context)
		end
		
		commandFinalize.prefix(message, context, "!vm")
	end
	
	if commandFinalize[command] then
		ids = commandParse(message, context, command)
		if not ids[1] then return ids end -- message for logger
		
		return commandFinalize[command](message, ids)
	end
end