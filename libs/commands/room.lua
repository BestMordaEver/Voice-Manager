local client = require "client"
local locale = require "locale"
local config = require "config"

local channels = require "storage".channels

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local roomInfoEmbed = require "embeds/roomInfo"
local greetingEmbed = require "embeds/greeting"

local hostPermissionCheck = require "funcs/hostPermissionCheck"
local templateInterpreter = require "funcs/templateInterpreter"
local enforceReservations = require "funcs/enforceReservations"
local ratelimiter = require "utils/ratelimiter"

local permission = require "discordia".enums.permission
local overwriteType = require "discordia".enums.overwriteType

local tierRate = {[0] = 96,128,256,384}
local tierLocale = {[0] = "bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}

ratelimiter("channelName", 2, 600)

local function reprivilegify (voiceChannel)
	for _, permissionOverwrite in pairs(voiceChannel.permissionOverwrites) do
		if permissionOverwrite.type == overwriteType.member and
			permissionOverwrite:getObject().voiceChannel ~= voiceChannel and
			permissionOverwrite:getObject() ~= voiceChannel.guild.me then

			permissionOverwrite:delete()
		end
	end

	for _, member in pairs(voiceChannel.connectedMembers) do
		voiceChannel:getPermissionOverwriteFor(member):allowPermissions(permission.connect, permission.readMessages)
	end
end

local subcommands = {
	rename = function (interaction, voiceChannel, name)
		local limit, retryIn = ratelimiter:limit("channelName", voiceChannel.id)
		if limit == -1 then
			return "Ratelimit reached", warningEmbed(locale.ratelimitReached:format(retryIn))
		end

		local channelData, success, err = channels[voiceChannel.id]
		local parent = channelData.parent

		if parent and parent.template and parent.template:match("%%rename%%") then
			success, err = voiceChannel:setName(templateInterpreter(parent.template, interaction.member or voiceChannel.guild:getMember(interaction.user), channelData.position, name))
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
		local tier = voiceChannel.guild.premiumTier

		for _,feature in ipairs(voiceChannel.guild.features) do
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

	blocklist = function (interaction, voiceChannel)
		local user, subcommand = interaction.option.option.option, interaction.option.option.name
		user = user and user.value
		if user == client.user then
			return "Attempt to block the bot", warningEmbed(locale.shame)
		end

		local overwrite = user and voiceChannel:getPermissionOverwriteFor(voiceChannel.guild:getMember(user))

		if subcommand == "add" then
			overwrite:denyPermissions(permission.connect, permission.sendMessages)	-- sendMessages is used as an indication of blocklist, to not conflict with password flow
			return "Blocked mentioned members", okEmbed(locale.blockConfirm:format(user.mentionString))

		elseif subcommand == "remove" then
			overwrite:clearPermissions(permission.connect, permission.sendMessages)
			return "Unblocked mentioned members", okEmbed(locale.unblockConfirm:format(user.mentionString))

		elseif subcommand == "clear" then
			for _, permissionOverwrite in ipairs(voiceChannel.permissionOverwrites:toArray(function (permissionOverwrite) return permissionOverwrite.type == overwriteType.member end)) do
				permissionOverwrite:clearPermissions(permission.connect, permission.sendMessages)
			end
			return "Cleared blocklist", okEmbed(locale.blocklistClear:format())
		end
	end,

	reservations = function (interaction, voiceChannel)
		local user, subcommand = interaction.option.option.option, interaction.option.option.name
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
			for _, permissionOverwrite in ipairs(voiceChannel.permissionOverwrites:toArray(function (permissionOverwrite)
				return permissionOverwrite.type == overwriteType.member and permissionOverwrite:getObject() ~= permissionOverwrite.guild.me
			end)) do
				permissionOverwrite:clearPermissions(permission.connect, permission.readMessages)
			end
			enforceReservations(voiceChannel)
			return "Cleared reservations", okEmbed(locale.reservationsClear:format())
		end
	end,

	lock = function (interaction, voiceChannel)
		reprivilegify(voiceChannel)

		local guild, parent = voiceChannel.guild, channels[voiceChannel.id].parent
		voiceChannel:getPermissionOverwriteFor(parent and guild:getRole(parent.role) or guild.defaultRole):denyPermissions(permission.connect)
		return "Locked the room", okEmbed(locale.lockConfirm)
	end,

	unlock = function (interaction, voiceChannel)
		reprivilegify(voiceChannel)

		local guild, parent = voiceChannel.guild, channels[voiceChannel.id].parent
		local role = parent and guild:getRole(parent.role) or guild.defaultRole
		if voiceChannel.parent ~= voiceChannel.guild and voiceChannel.parent:getPermissionOverwriteFor(role):getAllowedPermissions():has(permission.connect) then
			voiceChannel:getPermissionOverwriteFor(role):allowPermissions(permission.connect)
		else
			voiceChannel:getPermissionOverwriteFor(role):clearPermissions(permission.connect)
		end

		return "Unlocked the room", okEmbed(locale.unlockConfirm)
	end,

	kick = function (interaction, voiceChannel, user)
		local member = voiceChannel.guild:getMember(user)
		if member.voiceChannel == voiceChannel then
			member:setVoiceChannel()
		end
		return "Kicked member", okEmbed(locale.kickConfirm:format(user.mentionString))
	end,

	invite = function (interaction, voiceChannel, user)
		local tryReservation = channels[voiceChannel.id].host == interaction.user.id and
			hostPermissionCheck(interaction.member or voiceChannel.guild:getMember(interaction.user), voiceChannel, "moderate")
		local invite = voiceChannel:createInvite()

		if invite then
			if user then
				if user:getPrivateChannel() then
					user:getPrivateChannel():sendf(locale.inviteText, interaction.user.tag, voiceChannel.name, invite.code)
					if tryReservation then
						voiceChannel:getPermissionOverwriteFor(voiceChannel.guild:getMember(user)):allowPermissions(permission.connect, permission.speak)
					end
					return "Sent invites to mentioned user", okEmbed(locale.inviteConfirm:format(user.mentionString))
				else
					return "Can't contact user", warningEmbed(locale.noDMs:format(invite.code))
				end
			else
				return "Created invite in room", okEmbed(locale.inviteCreated:format(invite.code))
			end
		else
			return "Bot isn't permitted to create invites", warningEmbed(locale.inviteError)
		end
	end,

	mute = function (interaction, voiceChannel, user)
		local guild, silentRoom = voiceChannel.guild
		local member = guild:getMember(user)

		if guild.afkChannel then
			silentRoom = guild.afkChannel
		else
			silentRoom = voiceChannel.category:createVoiceChannel("Silent room")
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

		if silentRoom and silentRoom ~= guild.afkChannel then silentRoom:delete() end

		return "Muted mentioned members", okEmbed(locale.muteConfirm:format(user.mentionString))
	end,

	unmute = function (interaction, voiceChannel, user)
		voiceChannel:getPermissionOverwriteFor(voiceChannel.guild:getMember(user)):clearPermissions(permission.speak)
		return "Unmuted mentioned members", okEmbed(locale.unmuteConfirm:format(user.mentionString))
	end,

	host = function (interaction, voiceChannel, user)
		local channelData = channels[voiceChannel.id]
		local host = client:getUser(channelData.host)

		if user then
			if interaction.user == host then
				local guild = voiceChannel.guild
				if guild:getMember(user).voiceChannel == voiceChannel then
					channelData:setHost(user.id)

					if channelData.parent then
						local perms = channelData.parent.permissions:toDiscordia()
						if #perms ~= 0 then
							local member, oldMember = guild:getMember(user.id), guild:getMember(host.id)

							if guild.me:getPermissions(voiceChannel):has(permission.manageRoles, table.unpack(perms)) then
								voiceChannel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
								voiceChannel:getPermissionOverwriteFor(oldMember):clearPermissions(table.unpack(perms))
							end

							local companion = client:getChannel(channelData.companion)
							if companion then
								if #perms ~= 0 and guild.me:getPermissions(companion):has(permission.manageRoles, table.unpack(perms)) then
									companion:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
									companion:getPermissionOverwriteFor(oldMember):allowPermissions(table.unpack(perms))
								end
							end
						end
					end

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
	end,

	password = function (interaction, voiceChannel, password)
		channels[voiceChannel.id]:setPassword(password)

		if password then
			return "New password set", okEmbed(locale.passwordConfirm:format(password))
		else
			return "Password reset", okEmbed(locale.passwordReset)
		end
	end,

	passwordinit = function (interaction)	-- not exposed, access via componentInteraction
		interaction:createModal("room_passwordcheck", locale.passwordEnter, {{type = 1, components = {{type = 4, custom_id = "password", label = locale.password, style = 1}}}})
		return "Created password modal"
	end,

	passwordcheck = function (interaction, voiceChannel)	-- not exposed, access via modalInteraction
		local channelData = channels[voiceChannel.id]
		local channel = client:getChannel(channelData and channelData.parent.id)

		if not channel then
			if channelData and channelData.parentType == 3 then voiceChannel:delete() end
			return "No parent channel", warningEmbed(locale.passwordNoChannel)
		elseif interaction.components[1].components[1].value == channelData.parent.password then
			local member = voiceChannel.guild:getMember(interaction.user)

			-- sendMessages is used as an indication of blocklist, to not conflict with password flow
			if channel:getPermissionOverwriteFor(member):getDeniedPermissions():has(permission.sendMessages) then
				if channelData and channelData.parentType == 3 then voiceChannel:delete() end
				return "User is banned", warningEmbed(locale.passwordBanned)
			end

			channel:getPermissionOverwriteFor(member):allowPermissions(permission.connect)
			member:setVoiceChannel(channel.id)
			return "Successfull password check", okEmbed(locale.passwordSuccess)
		else
			return "Failed password check", warningEmbed(locale.passwordFailure)
		end
	end,

	widget = function (interaction, voiceChannel)	-- not exposed, access via componentInteraction
		local argument, log, ov = interaction.values[1]

		do
			local guild, parent = voiceChannel.guild, channels[voiceChannel.id].parent
			ov = voiceChannel:getPermissionOverwriteFor(parent and guild:getRole(parent.role) or guild.defaultRole)
		end

		if argument == "lock" then
			reprivilegify(voiceChannel)
			ov:denyPermissions(permission.connect, permission.sendMessages)
			if voiceChannel.parent ~= voiceChannel.guild and ov:getAllowedPermissions():has(permission.readMessages) then
				ov:allowPermissions(permission.readMessages)
			else
				ov:clearPermissions(permission.readMessages)
			end

			log = "Locked the room"
		elseif argument == "hide" then
			reprivilegify(voiceChannel)
			ov:denyPermissions(permission.readMessages)

			log = "Room is hidden"
		elseif argument == "open" then
			if voiceChannel.parent ~= voiceChannel.guild and ov:getAllowedPermissions():has(permission.connect, permission.sendMessages, permission.readMessages) then
				ov:allowPermissions(permission.connect, permission.sendMessages, permission.readMessages)
			else
				ov:clearPermissions(permission.connect, permission.sendMessages, permission.readMessages)
			end

			log = "Opened the room"
		end

		interaction:deferUpdate()
		return log
	end
}

local noAdmin = {host = true, invite = true, passwordinit = true, passwordcheck = true}

return function (interaction, subcommand, argument)
	local member = interaction.member
	if not member then
		local guild = interaction.user.mutualGuilds:find(function (guild) return guild:getMember(interaction.user).voiceChannel end)
		if guild then member = guild:getMember(interaction.user) end
	end

	if not (member and member.voiceChannel and channels[member.voiceChannel.id]) then
		return "User not in room", warningEmbed(locale.notInRoom)
	end

	local voiceChannel = member.voiceChannel
	if subcommand == "view" then
		return "Sent room info", roomInfoEmbed(voiceChannel)
	end

	if noAdmin[subcommand] or member:hasPermission(voiceChannel, permission.administrator) or config.owners[interaction.user.id] then
		return subcommands[subcommand](interaction, voiceChannel, argument)
	elseif channels[voiceChannel.id].host == interaction.user.id then
		if hostPermissionCheck(member, voiceChannel, subcommand) then
			return subcommands[subcommand](interaction, voiceChannel, argument)
		end
		return "Insufficient permissions", warningEmbed(locale.badHostPermission)
	end
	return "Not a host", warningEmbed(locale.notHost)
end
