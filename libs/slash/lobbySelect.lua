local channelType = require "discordia".enums.channelType

local B = require "slash/builders"
local locale = require "locale/localeHandler"

return B.channel(
	locale.lobby,
	locale.lobbyConfigured,
	{channelType.voice},
	{required = true}
)