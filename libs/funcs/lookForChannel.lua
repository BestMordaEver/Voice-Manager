local client = require "client"

return function (message, input)
	local channel = client:getChannel(input)
	if channel and channel.guild == message.guild then
		return channel
	end

	input = input:lower()
	for _,channel in pairs(message.guild.voiceChannels) do
		if channel.name:lower() == input then return channel end
	end
	for _,channel in pairs(message.guild.textChannels) do
		if channel.name:lower() == input then return channel end
	end
	for _, channel in pairs(message.guild.categories) do
		if channel.name:lower() == input then return channel end
	end
end