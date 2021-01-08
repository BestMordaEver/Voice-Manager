local locale = require "locale"
local guilds = require "storage/guilds"

return function (message, prefix)
	guilds[message.guild.id]:setPrefix(prefix)
	message:reply(locale.prefixConfirm:format(prefix))
	return "Server prefix set"
end