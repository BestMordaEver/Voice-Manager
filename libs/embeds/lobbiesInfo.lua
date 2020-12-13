local config = require "config"
local locale = require "locale"
local client = require "discordia".storage.client

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"

-- no embed data is saved, since this is non-interactive embed
return function (message, guild)
	local guildData = guilds[guild.id]
	
	local embed = {
		title = locale.lobbiesInfoTitle:format(guild.name),
		color = config.embedColor,
		description = #guildData.lobbies == 0 and locale.lobbiesNoInfo or locale.lobbiesInfo,
		fields = {}
	}
	
	for lobbyData, _ in pairs(guildData.lobbies) do
		lobbyData = lobbies[lobbyData]
		if not lobbyData.isMatchmaking then
			table.insert(embed.fields, {
				name = client:getChannel(lobbyData.id).name,
				value = locale.lobbiesField:format(
					client:getChannel(lobbyData.target),
					lobbyData.template,
					tostring(lobbyData.permissions),
					lobbyData.capacity,
					lobbyData.companionCategory and "Enabled" or "Disabled",
					#lobbyData.children
				),
				inline = true
			})
		end
	end
	
	message:reply({embed = embed})
end

--[[**Target:** %s
**Template:** %s
**Permissions:** %s
**Capacity:** %d
**Companion:** %s
**Channels:** %d]]