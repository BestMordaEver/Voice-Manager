local logger = require "logger"
local client = require "client"

local commands = require "commands/init"

local errorResponse = require "response/error"

return function (interaction)

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s: %s component triggered", interaction.guild.id, interaction.user.id, interaction.customId)
	else
		logger:log(4, "USER %s in DMs: %s component triggered", interaction.user.id, interaction.customId)
	end

	local command, primary, secondary = interaction.customId:match("^(.-)_(.-)_(.-)$")
	if secondary then
		secondary = tonumber(secondary) or secondary -- delete_row_1 or room_widget_lock
	else
		command, primary = interaction.customId:match("^(.-)_(.-)$")
		primary = tonumber(primary) or primary -- help_1 or delete_nuke
	end

	if interaction.values then
		secondary = client:getChannel(interaction.values[1])
	end

	local res, logMsg, reply = xpcall(commands[command], debug.traceback, interaction, primary, secondary)

	if res then
		if interaction.guild then
			logger:log(4, "GUILD %s USER %s: %s", interaction.guild.id, interaction.user.id, logMsg)
		else
			logger:log(4, "USER %s in DMs: %s", interaction.user.id, logMsg)
		end

		if interaction.isReplied and reply then
			interaction:followup(reply)
		elseif reply then
			interaction:update(reply)
		else
			interaction:deferUpdate()
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