local logger = require "logger"

local commands = require "commands/init"

local errorResponse = require "response/error"

return function (interaction)
	interaction:deferReply(true)

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s: %s modal submitted", interaction.guild.id, interaction.user.id, interaction.customId)
	else
		logger:log(4, "USER %s in DMs: %s modal submitted", interaction.user.id, interaction.customId)
	end

	local command = interaction.customId:match("^[^_]+")
	local argument = interaction.customId:match("_([^_]+)")

	local res, logMsg, reply = xpcall(commands[command], debug.traceback, interaction, argument)

	if res then
		if interaction.guild then
			logger:log(4, "GUILD %s USER %s: %s", interaction.guild.id, interaction.user.id, logMsg)
		else
			logger:log(4, "USER %s in DMs: %s", interaction.user.id, logMsg)
		end

		if reply then
			local ok, msg
			if interaction.isReplied then
				ok, msg = interaction:updateReply(reply)
				if not ok then error(string.format("failed to update reply - %s\n", msg)) end
			else
				ok, msg = interaction:reply(reply)
				if not ok then error(string.format("failed to reply - %s\n", msg)) end
			end
		elseif not interaction.isReplied then
			interaction:reply(errorResponse(true, interaction.locale))
			error(string.format('modal %s failed to reply', interaction.customId))
		end
	else
		if interaction.isReplied then
			interaction:updateReply(errorResponse(true, interaction.locale))
		else
			interaction:reply(errorResponse(true, interaction.locale))
		end
		error(string.format('failed to process the modal "%s"\n%s', interaction.customId, logMsg))
	end

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s: %s modal processed", interaction.guild.id, interaction.user.id, interaction.customId)
	else
		logger:log(4, "USER %s in DMs: %s modal processed", interaction.user.id, interaction.customId)
	end
end