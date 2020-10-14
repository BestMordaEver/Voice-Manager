local client = require "discordia".storage.client
local lobbies = require "storage/lobbies"
local actionParse = require "utils/actionParse"
local finalizer = require "finalizer"
local locale = require "locale"

-- this function is also used by embeds, they will supply ids and resize value
return function (message, ids, resize)
	if not ids then
		resize = message.content:match('resize%s*.-%s*(%d+)$') or message.content:match("resize%s*(%d+)$")
		
		ids = actionParse(message, message.content:match('resize%s*(.-)%s*%d+$') or message.content:match('resize%s*(.-)$'), "resize", resize)
		if not ids[1] then return ids end -- message for logger
	end
	
	if not resize then
		message:reply(lobbies[ids[1]].resize and locale.lobbyTemplate:format(client:getChannel(ids[1]).name, lobbies[ids[1]].template) or locale.noTemplate)
		return "Sent channel template"
	end
	
	template, ids = finalizer.template(message, ids, template)
	message:reply(template)
	return (#ids == 0 and "Successfully applied template to all" or ("Couldn't apply template to "..table.concat(ids, " ")))
end