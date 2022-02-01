local client = require "client"
local locale = require "locale"
local config = require "config"

local guilds = require "storage/guilds"
local channels = require "storage/channels"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local roomInfoEmbed = require "embeds/roomInfo"

local hostPermissionCheck = require "funcs/hostPermissionCheck"
local templateInterpreter = require "funcs/templateInterpreter"
local enforceReservations = require "funcs/enforceReservations"
local ratelimiter = require "utils/ratelimiter"

local permission = require "discordia".enums.permission

local tierRate = {[0] = 96,128,256,384}
local tierLocale = {[0] = "bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}

ratelimiter("channelName", 2, 600)

local subcommands = {
	rename = function (interaction, voiceChannel, name)
		local limit, retryIn = ratelimiter:limit("channelName", voiceChannel.id)
		if limit == -1 then
			return "Ratelimit reached", warningEmbed(locale.ratelimitReached:format(retryIn))
		end

		local channelData, success, err = channels[voiceChannel.id]

		if channelData.parent and channelData.parent.template and channelData.parent.template:match("%%rename%%") then
			success, err = voiceChannel:setName(templateInterpreter(channelData.parent.template, interaction.member, channelData.position, name))
		else
			success, err = voiceChannel:setName(name)
		end

		if success then
			return "Successfully changed room name", okEmbed(locale.nameConfirm:format(voiceChannel.name).."\n"..locale[limit == 0 and "ratelimitReached" or "ratelimitRemaining"]:format(retryIn))
		end

		return "Couldn't change room name: "..err, warningEmbed(locale.renameError)
	end,

	resize = function (interaction, voiceChannel, size)
		local success, err = voiceChannel:setUserLimit(size)
		if success then
			return "Successfully changed room capacity", okEmbed(locale.capacityConfirm:format(size))
		else
			return "Couldn't change room capacity: "..err, warningEmbed(locale.resizeError)
		end
	end,

	bitrate = function (interaction, voiceChannel, bitrate)
		local tier = interaction.guild.premiumTier

		for _,feature in ipairs(interaction.guild.features) do
			if feature == "VIP_REGIONS" then tier = 3 end
		end

		if bitrate > tierRate[tier] then
			return "Bitrate OOB", warningEmbed(locale[tierLocale[tier]])
		end

		local success, err = voiceChannel:setBitrate(bitrate * 1000)
		if success then
			return "Successfully changed room bitrate", okEmbed(locale.bitrateConfirm:format(bitrate))
		else
			return "Couldn't change room bitrate: "..err, warningEmbed(locale.bitrateError)
		end
	end,

	blocklist = function (interaction, voiceChannel, subcommand)
		local user = interaction.option.option.option
		user = user and user.value
		local overwrite = user and voiceChannel:getPermissionOverwriteFor(voiceChannel.guild:getMember(user))

		if subcommand == "add" then
			overwrite:denyPermissions(permission.connect)
			return "Blocked mentioned members", okEmbed(locale.blockConfirm:format(user.mentionString))

		elseif subcommand == "remove" then
			overwrite:clearPermissions(permission.connect)
			return "Unblocked mentioned members", okEmbed(locale.unblockConfirm:format(user.mentionString))

		elseif subcommand == "clear" then
			local mentionString = ""
			for _, permissionOverwrite in ipairs(voiceChannel.permissionOverwrites:toArray(function (permissionOverwrite) return permissionOverwrite.type == "member" end)) do
				mentionString = mentionString .. permissionOverwrite:getObject().user.mentionString .. " "
				permissionOverwrite:clearPermissions(permission.connect)
			end
			return "Cleared blocklist", okEmbed(locale.unblockConfirm:format(mentionString))
		end
	end,

	reservations = function (interaction, voiceChannel, subcommand)
		local user = interaction.option.option.option
		user = user and user.value
		local overwrite = user and voiceChannel:getPermissionOverwriteFor(voiceChannel.guild:getMember(user))

		if subcommand == "add" then
			overwrite:allowPermissions(permission.connect, permission.readMessages)
			enforceReservations(voiceChannel)
			return "Reserved mentioned members", okEmbed(locale.reserveConfirm:format(user.mentionString))

		elseif subcommand == "remove" then
			overwrite:clearPermissions(permission.connect, permission.readMessages)
			enforceReservations(voiceChannel)
			return "Unreserved mentioned members", okEmbed(locale.unreserveConfirm:format(user.mentionString))

		elseif subcommand == "clear" then
			local mentionString = ""
			for _, permissionOverwrite in ipairs(voiceChannel.permissionOverwrites:toArray(function (permissionOverwrite)
				return permissionOverwrite.type == "member" and permissionOverwrite:getObject() ~= permissionOverwrite.guild.me
			end)) do
				mentionString = mentionString .. permissionOverwrite:getObject().user.mentionString .. " "
				permissionOverwrite:clearPermissions(permission.connect, permission.readMessages)
			end
			enforceReservations(voiceChannel)
			return "Cleared reservations", okEmbed(locale.unreserveConfirm:format(mentionString))
		end
	end,

	lock = function (interaction, voiceChannel)
		local mentionString = ""
		for _, member in pairs(voiceChannel.connectedMembers) do
			voiceChannel:getPermissionOverwriteFor(member):allowPermissions(permission.connect, permission.readMessages)
		end

		local guild = voiceChannel.guild
		voiceChannel:getPermissionOverwriteFor(guild:getRole(guilds[guild.id].role) or guild.defaultRole):denyPermissions(permission.connect)
		return "Locked the room", okEmbed(locale.lockConfirm:format(mentionString))
	end,

	kick = function (interaction, voiceChannel, user)
		interaction.guild:getMember(user):setVoiceChannel()
		return "Kicked member", okEmbed(locale.kickConfirm:format(user.mentionString))
	end,

	invite = function (interaction, voiceChannel, user)
		local tryReservation = channels[voiceChannel.id].host == interaction.author.id and hostPermissionCheck(interaction.member, voiceChannel, "moderate")
		local invite = voiceChannel:createInvite()

		if invite then
			invite = "https://discord.gg/"..invite.code
			if user then
				if user:getPrivateChannel() then
					user:getPrivateChannel():send(invite)
					if tryReservation then
						voiceChannel:getPermissionOverwriteFor(voiceChannel.guild:getMember(user)):allowPermissions(permission.connect, permission.speak)
					end
					return "Sent invites to mentioned user", okEmbed(locale.inviteConfirm:format(user.mentionString))
				else
					return "Can't contact user", warningEmbed(locale.noDMs:format(invite))
				end
			else
				return "Created invite in room", invite
			end
		else
			return "Bot isn't permitted to create invites", warningEmbed(locale.inviteError)
		end
	end,

	mute = function (interaction, voiceChannel, user)
		local guild, silentRoom = interaction.guild
		local member = guild:getMember(user)

		if guild.afkChannel then
			silentRoom = guild.afkChannel
		else
			silentRoom = interaction.category:createVoiceChannel("Silent room")
			if not silentRoom then
				silentRoom = guild:createVoiceChannel("Silent room")
			end
			if not silentRoom then silentRoom = nil end
		end

		voiceChannel:getPermissionOverwriteFor(member):denyPermissions(permission.speak)
		if member.voiceChannel == voiceChannel then
			member:setVoiceChannel(silentRoom)
			if silentRoom then member:setVoiceChannel(voiceChannel) end
		end

		if silentRoom ~= guild.afkChannel then silentRoom:delete() end

		return "Muted mentioned members", okEmbed(locale.muteConfirm:format(user.mentionString))
	end,

	unmute = function (interaction, voiceChannel, user)
		voiceChannel:getPermissionOverwriteFor(interaction.guild:getMember(user)):clearPermissions(permission.speak)
		return "Unmuted mentioned members", okEmbed(locale.unmuteConfirm:format(user.mentionString))
	end,

	host = function (interaction, voiceChannel, user)
		local channelData = channels[voiceChannel.id]
		local host = client:getUser(channelData.host)

		if user then
			if interaction.user == host then
				if interaction.guild:getMember(user).voiceChannel == voiceChannel then
					channelData:setHost(user.id)
					return "Promoted a new host", okEmbed(locale.hostConfirm:format(user.mentionString))
				else
					return "Can't promote person not in a room", warningEmbed(locale.badNewHost)
				end
			else
				return "Not a host", warningEmbed(locale.notHost)
			end
		else
			if host then
				return "Pinged the host", okEmbed(locale.hostIdentify:format(host.mentionString))
			else
				return "Didn't find host", warningEmbed(locale.badHost)
			end
		end
	end
}

local noAdmin = {host = true, invite = true}

return function (interaction, subcommand, argument)
	local voiceChannel = interaction.member.voiceChannel

	if not channels[voiceChannel.id] then
		return "User not in room", warningEmbed(locale.notInRoom)
	end

	if subcommand == "view" then
		return "Sent room info", roomInfoEmbed(voiceChannel)
	end

	if noAdmin[subcommand] or interaction.member:hasPermission(voiceChannel, permission.administrator) or config.owners[interaction.user.id] then
		return subcommands[subcommand](interaction, voiceChannel, argument)
	elseif channels[voiceChannel.id].host == interaction.user.id then
		if hostPermissionCheck(interaction.member, voiceChannel, subcommand) then
			return subcommands[subcommand](interaction, voiceChannel, argument)
		end
		return "Not a host", warningEmbed(locale.notHost)
	end
	return "Insufficient permissions", warningEmbed(locale.badHostPermission)
end
