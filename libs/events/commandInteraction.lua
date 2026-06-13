local logger = require "logger"
local uv = require "uv"

local commands = require "commands/init"
local metrics = require "telemetry/metrics"

local errorResponse = require "response/error"

local insert, concat = table.insert, table.concat
local hrtime = uv.hrtime

return function (interaction)
	local strings = {
		interaction.commandName,
		interaction.subcommand or (interaction.target and tostring(interaction.target)),
		interaction.subcommandOption
	}
	if interaction.options then
		for name, option in pairs(interaction.options) do
			insert(strings, name)
			insert(strings, tostring(option.value))
		end
	end
	local commandString = concat(strings, " ")

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s invoked a command: %s", interaction.guild.id, interaction.user.id, commandString)
	else
		logger:log(4, "USER %s invoked a commandin DMs: %s", interaction.user.id, commandString)
	end

	-- call the command, log it, and all in protected call
	local start = hrtime()
	local res, logMsg, reply = xpcall(commands, debug.traceback, interaction)

	-- record slash command usage for telemetry
	metrics.counter("voicemanager_commands_total", 1,
		{command = interaction.commandName, outcome = res and "success" or "error"})
	metrics.counter("voicemanager_command_duration_ms_sum", (hrtime() - start) / 1e6,
		{command = interaction.commandName})
	metrics.counter("voicemanager_command_duration_ms_count", 1,
		{command = interaction.commandName})

	-- notify user if failed
	if res then
		if interaction.guild then
			logger:log(4, "GUILD %s USER %s: %s", interaction.guild.id, interaction.user.id, logMsg)
		else
			logger:log(4, "USER %s in DMs: %s", interaction.user.id, logMsg)
		end

		if reply then -- may have created modal instead
			local ok, msg
			if interaction.isReplied then
				ok, msg = interaction:updateReply(reply)
				if not ok then error(string.format("failed to update reply - %s\n", msg)) end
			else
				ok, msg = interaction:reply(reply)
				if not ok then error(string.format("failed to reply - %s\n", msg)) end
			end
		end
		if not interaction.isReplied then
			interaction:reply(errorResponse(true, interaction.locale))
			error(string.format('failed to produce a reply to command %s', commandString))
		end
	else
		if interaction.isReplied then
			interaction:updateReply(errorResponse(true, interaction.locale))
		else
			interaction:reply(errorResponse(true, interaction.locale))
		end
		error(string.format('failed to execute the command "%s"\n%s', commandString, logMsg))
	end

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s: %s command completed", interaction.guild.id, interaction.user.id, interaction.commandName)
	else
		logger:log(4, "USER %s in DMs: %s command completed", interaction.user.id, interaction.commandName)
	end
end