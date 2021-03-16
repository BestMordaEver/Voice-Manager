local locale = require "locale"
local guilds = require "storage/guilds"

return function (message, prefix)
	if not prefix then prefix = "vm!" end
	guilds[message.guild.id]:setPrefix(prefix)
	return "Server prefix set", "ok", locale.prefixConfirm:format(prefix)
end