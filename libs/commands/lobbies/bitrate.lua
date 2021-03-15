local locale = require "locale"
local lobbies = require "storage/lobbies"

local tierRate = {96,128,256,384}
local tierLocale = {"bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}

return function (message, channel, bitrate)
	bitrate = tonumber(bitrate)
	local tier = message.guild.premiumTier
	for _,feature in ipairs(message.guild.features) do
		if feature == "VIP_REGIONS" then tier = 4 end
	end
	
	if not bitrate or bitrate < 8 or bitrate > tierRate[tier] then
		return "bitrate OOB", "warning", locale[tierLocale[tier]]
	else
		lobbies[channel.id]:setBitrate(bitrate*1000)
		return "Lobby bitrate set", "ok", locale.bitrateConfirm:format(bitrate)
	end
end