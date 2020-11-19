local client = require "discordia".storage.client
local guilds = require "storage/guilds"

return function (guild) -- triggers whenever new guild appears in bot's scope
	guilds:add(guild.id)
	client:getChannel("676432067566895111"):send((guild.name or "no name").." added me!\n")
end