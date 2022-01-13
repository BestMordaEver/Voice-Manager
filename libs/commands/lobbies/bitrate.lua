local locale = require "locale"
local lobbies = require "storage/lobbies"
local warningEmbed = require "embeds/warning"
local okEmbed = require "embeds/ok"

local tierRate = {[0] = 96,128,256,384}
local tierLocale = {[0] = "bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}

return function (interaction, channel, reset)
	local bitrate = reset and 64 or interaction.option.options.bitrate.value
	local tier = interaction.guild.premiumTier
	for _,feature in ipairs(interaction.guild.features) do
		if feature == "VIP_REGIONS" then tier = 3 end
	end

	if bitrate > tierRate[tier] then
		return "Bitrate OOB", warningEmbed(locale[tierLocale[tier]])
	else
		lobbies[channel.id]:setBitrate(bitrate*1000)
		return "Lobby bitrate set", okEmbed(locale.bitrateConfirm:format(bitrate))
	end
end