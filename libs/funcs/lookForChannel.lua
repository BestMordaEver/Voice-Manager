local client = require "client"
local guilds = require "storage/guilds"

return function (message, input)
	local channel = client:getChannel(input)
	if channel and channel.guild == message.guild then
		return channel
	end
	
	input = input:lower()
	for lobbyData,_ in pairs(guilds[message.guild.id].lobbies) do
		channel = client:getChannel(lobbyData.id)
		if channel and channel.name == input then return channel end
	end
	for _, channel in pairs(message.guild.categories) do
		if channel.name == input then return channel end
	end
end