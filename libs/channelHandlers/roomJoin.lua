local client = require "client"
local logger = require "logger"

local channels = require "storage/channels"

local passwordEmbed = require "embeds/password"

local enums = require "discordia".enums
local permission = enums.permission
local channelType = enums.channelType

-- user joined a room
return function (member, channel)
	local channelData = channels[channel.id]

	if channelData.password and not (
		member:hasPermission(channel, permission.administrator) or
		channel:getPermissionOverwriteFor(member):getAllowedPermissions():has(permission.connect)
 	) then
		logger:log(4, "GUILD %s ROOM %s USER %s: sending password prompt", channel.guild.id, channel.id, member.user.id)
		channel:getPermissionOverwriteFor(member):denyPermissions(permission.connect)

		local newChannel = channel.guild:createChannel {
			name = "Password verification",
			parent_id = (channel.category or channel.guild).id,
			type = channelType.voice,
			permission_overwrites = {
				{
					id = client.user.id,
					type = 1,
					allow = "3146752"
				},
				{
					id = channel.guild.id,
					type = 0,
					deny = "3146752"
				}
			}
		}

		channels:store(newChannel.id, 3, member.user.id, channel.id, 0)
		member:setVoiceChannel(newChannel)

		return member.user:send(passwordEmbed(member.user, channel))
	end

	logger:log(4, "GUILD %s ROOM %s USER %s: joined", channel.guild.id, channel.id, member.user.id)

	local companion = client:getChannel(channelData.companion)
	if companion and not companion:getPermissionOverwriteFor(member):getDeniedPermissions():has(permission.readMessages) then
		companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
	end
end
