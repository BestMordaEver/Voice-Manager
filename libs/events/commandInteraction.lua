local logger = require "logger"
local errorEmbed = require "embeds/error"
local commands = require "commands/init"

return function (interaction)
    if not interaction.guild then return end

    interaction:deferReply(true)
	logger:log(4, "GUILD %s USER %s: %s command invoked", interaction.guild.id, interaction.user.id, interaction.commandName)

	-- call the command, log it, and all in protected call
	local res, logMsg, reply = xpcall(commands, debug.traceback, interaction)

	-- notify user if failed
	if res then
		logger:log(4, "GUILD %s USER %s: %s", interaction.guild.id, interaction.user.id, logMsg)
        interaction:updateReply(reply or errorEmbed())	-- reply mustn't be empty
	else
		interaction:updateReply(errorEmbed())
		error(logMsg)
	end

	logger:log(4, "GUILD %s USER %s: %s command completed", interaction.guild.id, interaction.user.id, interaction.commandName)
end