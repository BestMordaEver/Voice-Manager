local locale = require "locale"
local lobbies = require "storage/lobbies"

return function (message, channel, bitrate)
	bitrate = tonumber(bitrate)
	if not bitrate or bitrate < 8 or bitrate > 96 then
		return "bitrate OOB", "warning", locale.bitrateOOB
	else
		lobbies[channel.id]:setBitrate(bitrate*1000)
		return "Lobby bitrate set", "ok", locale.bitrateConfirm:format(bitrate)
	end
end