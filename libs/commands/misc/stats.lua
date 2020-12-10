local discordia = require "discordia"
local locale = require "locale"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local client = discordia.storage.client

return function (message)
	local guildID = message.content:match("stats%s*(.-)$")
	local guild = guildID == "local" and message.guild or client:getGuild(guildID)
	
	if guild and not guild:getMember(message.author) then
		message:reply(locale.notMember)
		return "Not a member"
	end
	
	local t = os.clock()
	message.channel:broadcastTyping()
	t = math.modf((os.clock() - t)*1000)
	
	local guildCount, lobbyCount, channelCount, peopleCount = #client.guilds
	if guild then
		lobbyCount, channelCount, peopleCount = #guilds[guild.id].lobbies, guilds[guild.id].channels, channels:people(guild.id)
	else
		lobbyCount, channelCount, peopleCount = #lobbies, #channels, channels:people()
	end
	message:reply((guild and (
		lobbyCount == 1 and locale.lobby or locale.lobbies:format(lobbyCount)
		) or (
		(guildCount == 1 and lobbyCount == 1) and locale.serverLobby or string.format((
			guildCount == 1 and locale.serverLobbies or (
			lobbyCount == 1 and locale.serversLobby or 
			locale.serversLobbies)), guildCount, lobbyCount))) .. "\n" ..
		((channelCount == 1 and peopleCount == 1) and locale.channelPerson or string.format((
			channelCount == 1 and locale.channelPeople or (
			peopleCount == 1 and locale.channelsPerson or -- practically impossible, but whatever
			locale.channelsPeople)), channelCount, peopleCount)) .. "\n" ..
		string.format(locale.ping, t))
	return "Sent current stats"
end