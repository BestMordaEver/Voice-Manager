local logger = require "discordia".storage.logger

-- message is a discord object, if it doesn't have guild property - it's a DM
return function (message, logMsg)
	if message.guild then
		logger:log(4, "GUILD %s USER %s: %s", message.guild.id, message.author.id, logMsg)
	else
		logger:log(4, "DM %s: %s", message.author.id, logMsg)
	end
end