local client = require "discordia".storage.client
local commandParse = require "commands/commandParse"
local commandFinalize = require "commands/commandFinalize"

-- this function is also used by embeds, they will supply ids and template
return function (message, ids, template)
	if not ids then
		template = message.content:match('template%s*".-"%s*(.-)$') or message.content:match("template%s*(.-)$")
		
		ids = commandParse(message, message.content:match('"(.-)"'), "template", template)
		if not ids[1] then return ids end -- message for logger
	end
	
	return commandFinalize.template(message, ids, template)
end