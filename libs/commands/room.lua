local client = require "client"
local locale = require "locale"
local config = require "config"

local channels = require "handlers/storageHandler".channels

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local roomInfoEmbed = require "embeds/roomInfo"

local channelHandler = require "handlers/channelHandler"
local ratelimiter = require "utils/ratelimiter"

local permission = require "discordia".enums.permission
local interactionType = require "discordia".enums.interactionType

local tierRate = {[0] = 96,128,256,384}
local tierLocale = {[0] = "bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}

ratelimiter("channelName", 2, 600)

local subcommands
subcommands = {
	rename = function (interaction, channel)
		local type, name = interaction.option.option.name, interaction.option.option.option.value
		local channelData = channels[channel.id]
		local template = channelData.parent and channelData.parent.template

		if type == "text" then
			local companion = client:getChannel(channelData.companion)
			if not companion or companion == channel then
				return "No text channel to rename", warningEmbed(locale.renameNoText)
			end
			channel = companion
			template = channelData.parent and channelData.parent.companionTemplate
		end

		local limit, retryIn = ratelimiter:limit("channelName", channel.id)
		if limit == -1 then
			return "Ratelimit reached", warningEmbed(locale.ratelimitReached:format(retryIn))
		end

		local success, err

		if template and template:match("%%rename.-%%") then
			success, err = channel:setName(channelHandler.handleTemplate(template, interaction.member or channel.guild:getMember(interaction.user), channelData.position, name))
		else
			success, err = channel:setName(name)
		end

		if success then
			return "Successfully changed channel name", okEmbed(locale.nameConfirm:format(channel.name).."\n"..locale[limit == 0 and "ratelimitReached" or "ratelimitRemaining"]:format(retryIn))
		end

		return "Couldn't change channel name: "..err, warningEmbed(locale.renameError)
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

	host = function (interaction, voiceChannel, newHost)
		local channelData = channels[voiceChannel.id]
		local host = client:getUser(channelData.host)

		if newHost then
			if interaction.user ~= host then
				return "Not a host", warningEmbed(locale.notHost)
			end

			local guild = voiceChannel.guild
			newHost = guild:getMember(newHost)
			if newHost.voiceChannel ~= voiceChannel then
				return "Can't promote person not in a room", warningEmbed(locale.badNewHost)
			end

			channelData:setHost(newHost.user.id)

			if channelData.parent then
				channelHandler.adjustPermissions(voiceChannel, newHost, interaction.member)
			end

			return "Promoted a new host", okEmbed(locale.hostConfirm:format(newHost.user.mentionString))
		else
			if host then
				return "Pinged the host", okEmbed(locale.hostIdentify:format(host.mentionString))
			else
				return "Didn't find host", warningEmbed(locale.badHost)
			end
		end
	end,

	kick = function (interaction, voiceChannel, user)
		local member = voiceChannel.guild:getMember(user)
		if member.voiceChannel == voiceChannel then
			member:setVoiceChannel()
			return "Kicked member", okEmbed(locale.kickConfirm:format(user.mentionString))
		else
			return "Can't kick the user from a different room", warningEmbed(locale.kickNotInRoom)
		end
	end,

	mute = function (interaction, voiceChannel, scope)
		local user
		if interaction.type == interactionType.applicationCommand then
			scope = scope.name
			user = interaction.option.option.option and interaction.option.option.option.value
		end

		local overwriteTarget
		if user then
			overwriteTarget = voiceChannel.guild:getMember(user)
		else
			overwriteTarget = channels[voiceChannel.id].parent and client:getRole(channels[voiceChannel.id].parent.role) or voiceChannel.guild.defaultRole
		end

		if scope == "voice" or scope == "both" then
			if user then
				local guild = voiceChannel.guild

				voiceChannel:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.speak)

				if overwriteTarget.voiceChannel == voiceChannel then
					local silentRoom
					if guild.afkChannel then
						silentRoom = guild.afkChannel
					else
						silentRoom = voiceChannel.category:createVoiceChannel("Silent room")
						if not silentRoom then
							silentRoom = guild:createVoiceChannel("Silent room")
						end
						if not silentRoom then silentRoom = nil end
					end

					overwriteTarget:setVoiceChannel(silentRoom)
					if silentRoom then
						overwriteTarget:setVoiceChannel(voiceChannel)
						if silentRoom ~= guild.afkChannel then
							silentRoom:delete()
						end
					end
				end
			else
				for _, member in pairs(voiceChannel.connectedMembers) do
					local po = voiceChannel:getPermissionOverwriteFor(member)
					if not po:getAllowedPermissions():has(permission.speak) and member:hasPermission(permission.speak) then
						po:allowPermissions(permission.speak)
					end
				end

				voiceChannel:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.speak)
			end
		end

		local companion = client:getChannel(channels[voiceChannel.id].companion)
		if scope == "text" or scope == "both" then
			if user then
				voiceChannel:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.sendMessages)

				if channels[voiceChannel.id].companion then
					if companion then
						companion:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.sendMessages)
					end
				end
			else
				for _, member in pairs(voiceChannel.connectedMembers) do
					local po = voiceChannel:getPermissionOverwriteFor(member)
					if not po:getAllowedPermissions():has(permission.sendMessages) and member:hasPermission(permission.sendMessages) then
						po:allowPermissions(permission.sendMessages)
						if companion then
							companion:getPermissionOverwriteFor(member):allowPermissions(permission.sendMessages)
						end
					end
				end

				voiceChannel:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.sendMessages)
				if companion then
					companion:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.sendMessages)
				end
			end
		end

		if user then
			return "Muted mentioned user", okEmbed(locale.muteConfirm:format(user.mentionString))
		else
			return "Muted all users outside the room", okEmbed(locale.muteAllConfirm)
		end
	end,

	unmute = function (interaction, voiceChannel, scope)
		local user
		if interaction.type == interactionType.applicationCommand then
			scope = scope.name
			user = interaction.option.option.option and interaction.option.option.option.value
		end

		local overwriteTarget
		if user then
			overwriteTarget = voiceChannel.guild:getMember(user)
		else
			overwriteTarget = channels[voiceChannel.id].parent and client:getRole(channels[voiceChannel.id].parent.role) or voiceChannel.guild.defaultRole
		end

		if scope == "voice" or scope == "both" then
			voiceChannel:getPermissionOverwriteFor(overwriteTarget):allowPermissions(permission.speak)
		end

		local companion = client:getChannel(channels[voiceChannel.id].companion)
		if scope == "text" or scope == "both" then
			voiceChannel:getPermissionOverwriteFor(overwriteTarget):allowPermissions(permission.sendMessages)

			if companion then
					companion:getPermissionOverwriteFor(overwriteTarget):allowPermissions(permission.sendMessages)
			end
		end

		if user then
			return "Unmuted mentioned user", okEmbed(locale.unmuteConfirm:format(user.mentionString))
		else
			return "Unmuted all users outside the room", okEmbed(locale.unmuteAllConfirm)
		end
	end,

	hide = function (interaction, voiceChannel, scope)
		local user
		if interaction.type == interactionType.applicationCommand then
			scope = scope.name
			user = interaction.option.option.option and interaction.option.option.option.value
		end

		local overwriteTarget
		if user then
			overwriteTarget = voiceChannel.guild:getMember(user)
		else
			overwriteTarget = channels[voiceChannel.id].parent and client:getRole(channels[voiceChannel.id].parent.role) or voiceChannel.guild.defaultRole
		end

		if scope == "voice" or scope == "both" then
			if user then
				voiceChannel:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.readMessages)
			else
				for _, member in pairs(voiceChannel.connectedMembers) do
					local po = voiceChannel:getPermissionOverwriteFor(member)
					if not po:getAllowedPermissions():has(permission.readMessages) then
						po:allowPermissions(permission.readMessages)
					end
				end

				voiceChannel:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.readMessages)
			end
		end

		local companion = client:getChannel(channels[voiceChannel.id].companion)
		if scope == "text" or scope == "both" then
			if companion then
				if user then
					companion:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.readMessages)
				else
					for _, member in pairs(voiceChannel.connectedMembers) do
						local po = companion:getPermissionOverwriteFor(member)
						if not po:getAllowedPermissions():has(permission.readMessages) then
							po:allowPermissions(permission.readMessages)
						end
					end
					companion:getPermissionOverwriteFor(overwriteTarget):denyPermissions(permission.readMessages)
				end
			elseif scope == "text" then
				return "No companion to hide", warningEmbed(locale.hideNoCompanion)
			end
		end

		if user then
			return "Hid the channel from the mentioned user", okEmbed(locale.hideConfirm:format(user.mentionString))
		else
			return "Hid the channel from all users outside the room", okEmbed(locale.hideAllConfirm)
		end
	end,

	show = function (interaction, voiceChannel, scope)
		local user
		if interaction.type == interactionType.applicationCommand then
			scope = scope.name
			user = interaction.option.option.option and interaction.option.option.option.value
		end

		local overwriteTarget
		if user then
			overwriteTarget = voiceChannel.guild:getMember(user)
		else
			overwriteTarget = channels[voiceChannel.id].parent and client:getRole(channels[voiceChannel.id].parent.role) or voiceChannel.guild.defaultRole
		end

		if scope == "voice" or scope == "both" then
			voiceChannel:getPermissionOverwriteFor(overwriteTarget):allowPermissions(permission.readMessages)
		end

		local companion = client:getChannel(channels[voiceChannel.id].companion)
		if scope == "text" or scope == "both" then
			if companion then
				companion:getPermissionOverwriteFor(overwriteTarget):allowPermissions(permission.readMessages)
			elseif scope == "text" then
				return "No companion to show", warningEmbed(locale.showNoCompanion)
			end
		end

		if user then
			return "Channel is made visible to the mentioned user", okEmbed(locale.showConfirm:format(user.mentionString))
		else
			return "Channel is made visible to everyone", okEmbed(locale.showAllConfirm)
		end
	end,

	block = function (interaction, voiceChannel, user)
		if user == client.user then
			return "Attempt to block the bot", warningEmbed(locale.shame)
		end

		local member = voiceChannel.guild:getMember(user)
		voiceChannel:getPermissionOverwriteFor(member):denyPermissions(permission.connect)
		if member.voiceChannel == voiceChannel then
			member:setVoiceChannel()
		end
		return "Blocked the user", okEmbed(locale.blockConfirm:format(user.mentionString))
	end,

	unblock = function (interaction, voiceChannel, user)
		local member = voiceChannel.guild:getMember(user)
		voiceChannel:getPermissionOverwriteFor(member):allowPermissions(permission.connect)

		return "Unblocked the user", okEmbed(locale.unblockConfirm:format(user.mentionString))
	end,

	lock = function (interaction, voiceChannel)
		for _, member in pairs(voiceChannel.connectedMembers) do
			local po = voiceChannel:getPermissionOverwriteFor(member)
			if not po:getAllowedPermissions():has(permission.connect) then
				po:allowPermissions(permission.connect)
			end
		end

		local parent = channels[voiceChannel.id].parent
		local role = parent and voiceChannel.guild:getRole(parent.role) or voiceChannel.guild.defaultRole
		voiceChannel:getPermissionOverwriteFor(role):denyPermissions(permission.connect)

		return "Locked the room", okEmbed(locale.lockConfirm)
	end,

	unlock = function (interaction, voiceChannel)
		local parent = channels[voiceChannel.id].parent
		local role = parent and voiceChannel.guild:getRole(parent.role) or voiceChannel.guild.defaultRole
		voiceChannel:getPermissionOverwriteFor(role):allowPermissions(permission.connect)

		return "Unlocked the room", okEmbed(locale.unlockConfirm)
	end,

	invite = function (interaction, voiceChannel, user)
		local tryReservation = channels[voiceChannel.id].host == interaction.user.id and
			channelHandler.checkHostPermissions(interaction.member or voiceChannel.guild:getMember(interaction.user), voiceChannel, "moderate")
		local invite = voiceChannel:createInvite()

		if not invite then
			return "Bot isn't permitted to create invites", warningEmbed(locale.inviteError)
		end

		if not user then
			return "Created invite in room", okEmbed(locale.inviteCreated:format(invite.code))
		end

		if not user:getPrivateChannel() then
			return "Can't contact user", warningEmbed(locale.noDMs:format(invite.code))
		end

		user:getPrivateChannel():sendf(locale.inviteText, interaction.user.name, voiceChannel.name, invite.code)

		if tryReservation then
			voiceChannel:getPermissionOverwriteFor(voiceChannel.guild:getMember(user)):allowPermissions(permission.readMessages, permission.connect, permission.speak)
		end
		return "Sent invite to mentioned user", okEmbed(locale.inviteConfirm:format(user.mentionString))
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

	widget = function (interaction, voiceChannel, argument)	-- not exposed, access via componentInteraction
		local action, scope = argument:match("^(.-)_(.-)$")
		if not action then action = argument end
		interaction:deferReply(true)

		local log, embed = subcommands[action](interaction, voiceChannel, scope)
		interaction:updateReply(embed)

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
		if channelHandler.checkHostPermissions(member, voiceChannel, subcommand) then
			return subcommands[subcommand](interaction, voiceChannel, argument)
		end
		return "Insufficient permissions", warningEmbed(locale.badHostPermission)
	end
	return "Not a host", warningEmbed(locale.notHost)
end
