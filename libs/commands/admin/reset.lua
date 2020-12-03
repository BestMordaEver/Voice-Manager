local commandParse = require "commands/commandParse"
local commandFinalize = require "commands/commandFinalize"

-- this function is NOT used by embeds, they will call corresponding functions with nil value
return function (message)
	
	local action, context = message.content:match('reset%s*(%a*)%s*"(.-)"')
	if not action then
		action, context = message.content:match("reset%s*(%a*)%s*(.-)$")
	end
	
	if action == "register" then
		action = "unregister"
	elseif action == "unregister" then
		action = "register"
	elseif action == "limitation" then
		if context == "" then
			context = message.guild
		else
			context = client:getGuild(context)
		end

		commandFinalize.limitation(message, context, 500)
	elseif action == "prefix" then
		if context == "" then
			context = message.guild
		else
			context = client:getGuild(context)
		end
		
		commandFinalize.prefix(message, context, "!vm")
	end
	
	if commandFinalize[action] then
		ids = commandParse(message, context, action)
		if not ids[1] then return ids end -- message for logger
		
		return commandFinalize[action](message, ids)
	end
end