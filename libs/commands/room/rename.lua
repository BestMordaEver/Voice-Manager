local locale = require "locale"
local guilds = require "storage/guilds"
local channels = require "storage/channels"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"
local templateInterpreter = require "funcs/templateInterpreter"
local ratelimiter = require "utils/ratelimiter"

ratelimiter("channelName", 2, 60*10)

return function (message, name)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end
	
	local isPermitted = hostPermissionCheck(message.member, channel, "rename")
	if not isPermitted then
		return "Insufficient permissions", "warning", locale.badHostPermission
	end
	
	local limit, retryIn = ratelimiter:limit("channelName", channel.id)
	local success, err
	
	if limit == -1 then
		return "Ratelimit reached", "warning", locale.ratelimitReached:format(retryIn)
	else
		local channelData, guildData = channels[channel.id], guilds[channel.guild.id]
		if channelData.parent then
			if channelData.parent.template and channelData.parent.template:match("%%rename%%") then
				success, err = channel:setName(templateInterpreter(channelData.parent.template, message.member, channelData.position, name))
			end
		elseif guildData.template and guildData.template:match("%%rename%%") then
			success, err = channel:setName(templateInterpreter(guildData.template, message.member, channelData.position, name))
		else
			success, err = channel:setName(name)
		end
	end
	
	if success then
		return "Successfully changed channel name", "ok", locale.nameConfirm:format(channel.name).."\n"..locale[limit == 0 and "ratelimitReached" or "ratelimitRemaining"]:format(retryIn)
	else
		return "Couldn't change channel name: "..err, "warning", locale.hostError
	end
end