local pingEmbed = require "embeds/ping"
local Date = require "discordia".Date

return function (interaction)
    return "Pong", pingEmbed(Date() - Date(Date.parseSnowflake(interaction.id)), interaction.guild)
end