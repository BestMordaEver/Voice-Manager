local locale = require "locale"
local guilds = require "storage/guilds"

return function (message, limit)
	limit = tonumber(limit)
	
	if not limit or limit > 500 or limit < 0 then
		message:reply(locale.limitBadInput)
		return "Invalid limit value"
	end
	
	guilds[message.guild.id]:setLimit(limit)
	message:reply(locale.limitConfirm)
	return "Set limit to "..limit
end