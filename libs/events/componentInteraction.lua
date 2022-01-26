local logger = require "logger"

local helpEmbed = require "embeds/help"

return function (interaction)
    if not interaction.guild then return end

	logger:log(4, "GUILD %s USER %s: %s button pressed", interaction.guild.id, interaction.user.id, interaction.customId)

    local command, arg = interaction.customId:match("^(.-)_(.-)$")

    if command == "help" then
	    local message = helpEmbed(arg)
        interaction:update({embeds = message.embeds})
    end
end