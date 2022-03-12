local logger = require "logger"

local commands = require "commands/init"

local errorEmbed = require "embeds/error"

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
    if not interaction.guild then return end

    interaction:deferReply(true)

	local commandString = concat(stringer({interaction.commandName}, interaction.options), " ")
	logger:log(4, "GUILD %s USER %s invoked a command: %s", interaction.guild.id, interaction.user.id, commandString)

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