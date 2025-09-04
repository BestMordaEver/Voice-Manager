local logger = require "logger"

local commands = require "commands/init"

local errorResponse = require "response/error"

local insert, concat = table.insert, table.concat

local function stringer (strings, options)
	for name, option in pairs(options) do
		insert(strings, name)
		if option.value then
			insert(strings, tostring(option.value))
		end
		if option.options then
			stringer(strings, option.options)
		end
	end
	return strings
end

return function (interaction)
	local commandString = interaction.options and concat(stringer({interaction.commandName}, interaction.options), " ") or interaction.commandName

	if interaction.guild then
		logger:log(4, "GUILD %s USER %s invoked a command: %s", interaction.guild.id, interaction.user.id, commandString)
	else
		logger:log(4, "USER %s invoked a commandin DMs: %s", interaction.user.id, commandString)
	end

	-- call the command, log it, and all in protected call
	local res, logMsg, reply = xpcall(commands, debug.traceback, interaction)

	-- notify user if failed
	if res then
		if interaction.guild then
			logger:log(4, "GUILD %s USER %s: %s", interaction.guild.id, interaction.user.id, logMsg)
		else
			logger:log(4, "USER %s in DMs: %s", interaction.user.id, logMsg)
		end

		if reply then
			reply.ephemeral = true
        	local ok, msg
			if interaction.isReplied then
				ok, msg = interaction:updateReply(reply)
				if not ok then error(string.format("failed to update reply - %s\n", msg)) end
			else
				ok, msg = interaction:reply(reply)
				if not ok then error(string.format("failed to reply - %s\n", msg)) end
			end
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