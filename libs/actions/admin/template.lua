local client = require "discordia".storage.client
local lobbies = require "storage/lobbies"
local actionParse = require "utils/actionParse"
local finalizer = require "finalizer"
local locale = require "locale"

-- this function is also used by embeds, they will supply ids and template
return function (message, ids, template)
	if not ids then
		template = message.content:match('template%s*".-"%s*(.-)$') or message.content:match("template%s*(.-)$")
		
		ids = actionParse(message, message.content:match('"(.-)"'), "template", template)
		if not ids[1] then return ids end -- message for logger
	end
	
	if template == "" then
		message:reply(lobbies[ids[1]].template and locale.lobbyTemplate:format(client:getChannel(ids[1]).name, lobbies[ids[1]].template) or locale.noTemplate)
		return "Sent channel template"
	end
	
	template, ids = finalizer.template(message, ids, template)
	message:reply(template)
	return (#ids == 0 and "Successfully applied template to all" or ("Couldn't apply template to "..table.concat(ids, " ")))
end