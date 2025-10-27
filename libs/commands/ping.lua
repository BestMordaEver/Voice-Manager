local pingResponse = require "response/ping"
local Date = require "discordia".Date

return function (interaction)
	return "Pong", pingResponse(true,
		interaction.locale,
		Date() - Date(Date.parseSnowflake(interaction.id)),
		interaction.guild or interaction.user.mutualGuilds:find(function () return true end)
	)
end