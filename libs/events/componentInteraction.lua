local client = require "client"
local logger = require "logger"

local commands = require "commands/init"

local errorResponse = require "response/error"

return function (interaction)

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s: %s component triggered", interaction.guild.id, interaction.user.id, interaction.customId)
	else
		logger:log(4, "USER %s in DMs: %s component triggered", interaction.user.id, interaction.customId)
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

		if reply and not interaction.isReplied then
			interaction:update(reply)
		elseif not interaction.isReplied then
			interaction:reply(errorResponse(true, interaction.locale))
			error(string.format('failed to produce a reply to component %s', interaction.customId))
		end
	else
		if interaction.isReplied then
			interaction:followup(errorResponse(true, interaction.locale))
		else
			interaction:reply(errorResponse(true, interaction.locale))
		end
		error(string.format('failed to process the component "%s"\n%s', interaction.customId, logMsg))
	end

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s: %s component interaction completed", interaction.guild.id, interaction.user.id, interaction.customId)
	else
		logger:log(4, "USER %s in DMs: %s component interaction completed", interaction.user.id, interaction.customId)
	end
end