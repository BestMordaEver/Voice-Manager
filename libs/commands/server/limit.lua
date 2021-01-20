local locale = require "locale"
local guilds = require "storage/guilds"

return function (message, limit)
	limit = tonumber(limit)
	
	if not limit or limit > 500 or limit < 0 then
		return "Invalid limit value", "warning", locale.limitBadInput
	end
	
	guilds[message.guild.id]:setLimit(limit)
	return "Server limit set", "ok", locale.limitConfirm
end