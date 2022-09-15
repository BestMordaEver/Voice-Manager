local logger = require "logger"

local commands = require "commands/init"

local errorEmbed = require "embeds/error"

return function (interaction)
    interaction:deferReply(true)

	logger:log(4, "USER %s: %s modal submitted", interaction.user.id, interaction.customId)

	local command, primary, secondary = interaction.customId:match("^(.-)_(.-)_(.-)$") -- delete_row_1
	if not secondary then
		command, primary = interaction.customId:match("^(.-)_(.-)$") -- help_1 or delete_nuke
	end

	local res, logMsg, reply = xpcall(commands[command], debug.traceback, interaction, primary, secondary)

	if res then
		logger:log(4, "USER %s: %s", interaction.user.id, logMsg)
        interaction:updateReply(reply or errorEmbed())	-- reply mustn't be empty
	else
		interaction:updateReply(errorEmbed())
		error(logMsg)
	end

	logger:log(4, "USER %s: %s modal processed", interaction.user.id, interaction.customId)
end