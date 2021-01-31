local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"

return function (message, bitrate)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end
	
	local isPermitted = hostPermissionCheck(message.member, channel, "bitrate")
	if not isPermitted then
		return "Insufficient permissions", "warning", locale.badHostPermission
	end
	
	bitrate = tonumber(bitrate)
	if not bitrate or bitrate < 8 or bitrate > 96 then
		return "Bitrate OOB", "warning", locale.bitrateOOB
	end
	
	local success, err = channel:setBitrate(bitrate * 1000)
	if success then
		return "Successfully changed channel bitrate", "ok", locale.bitrateConfirm:format(bitrate)
	else
		return "Couldn't change channel bitrate: "..err, "warning", locale.hostError
	end
end