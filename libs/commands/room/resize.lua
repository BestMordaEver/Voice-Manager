local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"

return function (message, size)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end

	local isPermitted = hostPermissionCheck(message.member, channel, "resize")
	if not isPermitted then
		return "Insufficient permissions", "warning", locale.badHostPermission
	end

	size = tonumber(size)
	if not size or size < 0 or size > 99 then
		return "Resize OOB", "warning", locale.capacityOOB
	end

	local success, err = channel:setUserLimit(size)
	if success then
		return "Successfully changed room capacity", "ok", locale.capacityConfirm:format(size)
	else
		return "Couldn't change room capacity: "..err, "warning", locale.hostError
	end
end