local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"

local tierRate = {[0] = 96,128,256,384}
local tierLocale = {[0] = "bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}

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
	local tier = message.guild.premiumTier
	for _,feature in ipairs(message.guild.features) do
		if feature == "VIP_REGIONS" then tier = 3 end
	end
	
	if not bitrate or bitrate < 8 or bitrate > tierRate[tier] then
		return "Bitrate OOB", "warning", locale.bitrateOOB
	end
	
	local success, err = channel:setBitrate(bitrate * 1000)
	if success then
		return "Successfully changed room bitrate", "ok", locale.bitrateConfirm:format(bitrate)
	else
		return "Couldn't change room bitrate: "..err, "warning", locale.hostError
	end
end