local complexParse = require "actions/complexParse"
local actionFinalizer = require "finalizers/template"

-- this function is also used by embeds, they will supply ids and template
return function (message, ids, template)
	if not ids then
		ids, template = complexParse(message, "template")
		if not ids[1] then return ids end -- message for logger
	end
	
	template, ids = actionFinalizer(message, ids, "template"..(template or ""))
	message:reply(template)
	return (#ids == 0 and "Successfully applied template to all" or ("Couldn't apply template to "..table.concat(ids, " ")))
end