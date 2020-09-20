local actionFinalizer = require "finalizers/permissions"

return function (message, ids, permissions, toggle)
	if not ids then
		ids, permissions, toggle = message.content:match('permissions%s*"(.-)"%s*(%a*)%s*(.-)$')
		if scope then
			if permissions == "mute" then
				permissions = permission.muteMembers
			elseif permissions == "deafen" then
				permissions = permission.deafenMembers
			elseif permissions == "disconnect" then
				permissions = permission.moveMembers
			elseif permissions == "manage" then
				permissions = permission.manageChannels
			else
				message:reply(locale.noPermission)
				return "No permission was selected"
			end
			
			if toggle ~= "on" and toggle ~= "off" then
				message:reply(locale.noToggle)
				return "No toggle was selected"
			end
		else
		
		end
	end
	
	permission, ids = actionFinalizer(message, ids, "permissions"..(template or ""))
	message:reply(permission)
	return (#ids == 0 and "Successfully applied permission to all" or ("Couldn't apply permission to "..table.concat(ids, " ")))
end