local logger = require "logger"

local guilds = require "storage/guilds"
local channels = require "storage/channels"

local permission = require "discordia".enums.permission


return function (member, channel)
	logger:log(4, "GUILD %s CHANNEL %s USER %s: joined", channel.guild.id, channel.id, member.user.id)

	--[[ TODO
	local name = handleTemplate(guilds[channel.guild.id].template, member, position):match("^%s*(.-)%s*$")

	local position = #(channel.category and 
		channel.category.voiceChannels:toArray("position", function (vchannel) return vchannel.position <= channel.position end)
			or
		channel.guild.voiceChannels:toArray("position", function (vchannel) return not vchannel.category and vchannel.position <= channel.position end))
	]]

	channels:store(channel.id, 1, member.user.id, channel.guild.id, 0, nil)

	local perms = guilds[channel.guild.id].permissions:toDiscordia()
	if #perms == 0 or not channel.guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then return end
	channel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
end