local client = require "discordia".storage.client
local actionParse = require "utils/actionParse"
local prefinalizer = require "prefinalizer"

-- this function is also used by embeds, they will supply ids and template
return function (message, ids, template)
	if not ids then
		template = message.content:match('template%s*".-"%s*(.-)$') or message.content:match("template%s*(.-)$")
		
		ids = actionParse(message, message.content:match('"(.-)"'), "template", template)
		if not ids[1] then return ids end -- message for logger
	end
	
	return prefinalizer.template(message, ids, template)
end