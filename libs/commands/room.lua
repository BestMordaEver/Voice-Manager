local client = require "client"
local localeHandler = require "locale/runtime/localeHandler"
local config = require "config"

local channels = require "storage/channels"

local okResponse = require "response/ok"
local warningResponse = require "response/warning"
local roomInfoResponse = require "response/roomInfo"

local handleTemplate = require "channelUtils/handleTemplate"
local adjustHostPermissions = require "channelUtils/adjustHostPermissions"
local checkHostPermissions = require "channelUtils/checkHostPermissions"

local passwordModal = require "utils/components".passwordModal
local ratelimiter = require "utils/ratelimiter"

local permission = require "discordia".enums.permission
local interactionType = require "discordia".enums.interactionType

local tierRate = {[0] = 96,128,256,384}
local tierLocale = {[0] = "bitrateOOB","bitrateOOB1","bitrateOOB2","bitrateOOB3"}

ratelimiter("channelName", 2, 600)
ratelimiter("companionName", 2, 600)

local subcommands
subcommands = {
	rename = function (interaction, channel)
		local type, name = interaction.option.option.name, interaction.option.option.option.value
		local channelData = channels[channel.id]
		local template = channelData.parent and channelData.parent.template
		local ratelimit = "channelName"

		if type == "text" then
			local companion = client:getChannel(channelData.companion)
			if not companion or companion == channel then
				return "No text channel to rename", warningResponse(true, interaction.locale, "noCompanion")
			end
			channel = companion
			template = channelData.parent and channelData.parent.companionTemplate
			ratelimit = "companionName"
		end

		local limit, retryIn = ratelimiter:limit(ratelimit, channel.id)
		if limit == -1 then
			return "Ratelimit reached", warningResponse(true, interaction.locale, "nameRatelimitReached", retryIn)
		end

		local success, err

		if template and template:match("%%rename.-%%") then
			success, err = channel:setName(handleTemplate(template, interaction.member or channel.guild:getMember(interaction.user), channelData.position, name))
		else
			success, err = channel:setName(name)
		end

		if success then
			return "Successfully changed channel name", okResponse(true, interaction.locale, "renameConfirm", channel.name,
				localeHandler(interaction.locale, limit == 0 and "nameRatelimitReached" or "nameRatelimitRemaining", retryIn))
		end

		return "Couldn't change channel name: "..err, warningResponse(true, interaction.locale, "renameError")
	end,

	resize = function (interaction, voiceChannel, size)
		local success, err = voiceChannel:setUserLimit(size)
		if success then
			return "Successfully changed room capacity", okResponse(true, interaction.locale, "capacityConfirm", size)
		else
			return "Couldn't change room capacity: "..err, warningResponse(true, interaction.locale, "resizeError")
		end
	end,

	bitrate = function (interaction, voiceChannel, bitrate)
		local tier = voiceChannel.guild.premiumTier

		for _,feature in ipairs(voiceChannel.guild.features) do
			if feature == "VIP_REGIONS" then tier = 3 end
		end

		if bitrate > tierRate[tier] then
			return "Bitrate OOB", warningResponse(true, interaction.locale, tierLocale[tier])
		end

		local success, err = voiceChannel:setBitrate(bitrate * 1000)
		if success then
			return "Successfully changed room bitrate", okResponse(true, interaction.locale, "bitrateConfirm", bitrate)
		else
			return "Couldn't change room bitrate: "..err, warningResponse(true, interaction.locale, "bitrateError")
		end
	end,

	host = function (interaction, voiceChannel, newHost)
		local channelData = channels[voiceChannel.id]
		local host = client:getUser(channelData.host)

		if newHost then
			if interaction.user ~= host then
				return "Not a host", warningResponse(true, interaction.locale, "notHost")
			end

			local guild = voiceChannel.guild
			newHost = guild:getMember(newHost)
			if newHost.voiceChannel ~= voiceChannel then
				return "Can't promote person not in a room", warningResponse(true, interaction.locale, "badNewHost")
			end

			channelData:setHost(newHost.user.id)

			if channelData.parent then
				adjustHostPermissions(voiceChannel, newHost, interaction.member)
			end

			return "Promoted a new host", okResponse(true, interaction.locale, "hostConfirm", newHost.user.mentionString)
		else
			if host then
				return "Pinged the host", okResponse(true, interaction.locale, "hostIdentify", host.mentionString)
			else
				return "Didn't find host", warningResponse(true, interaction.locale, "badHost")
			end
		end
	end,

	kick = function (interaction, voiceChannel, user)
		local member = voiceChannel.guild:getMember(user)
		if member.voiceChannel == voiceChannel then
			member:setVoiceChannel()
			return "Kicked member", okResponse(true, interaction.locale, "kickConfirm", user.mentionString)
		else
			return "Can't kick the user from a different room", warningResponse(true, interaction.locale, "kickNotInRoom")
		end
	end,

	mute = function (interaction, voiceChannel, scope)
		local user
		if interaction.type == interactionType.applicationCommand then
			scope = scope.name
			user = interaction.option.option.option and interaction.option.option.option.value
		end

		local guild, member, roles = voiceChannel.guild
		if user then
			if user == client.user then
				return "Attempt to mute the bot", warningResponse(true, interaction.locale, "shame")
			end
			member = guild:getMember(user)
		else
			roles = channels[voiceChannel.id].parent and channels[voiceChannel.id].parent.roles or {}
		end

		if scope == "voice" or scope == "both" then
			if user then
				voiceChannel:getPermissionOverwriteFor(member):denyPermissions(permission.speak)

				if member.voiceChannel == voiceChannel then
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

					member:setVoiceChannel(silentRoom)
					if silentRoom then
						member:setVoiceChannel(voiceChannel)
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

				if #roles == 0 then
					voiceChannel:getPermissionOverwriteFor(guild.defaultRole):denyPermissions(permission.speak)
				else for role in pairs(roles) do
					voiceChannel:getPermissionOverwriteFor(guild:getRole(role)):denyPermissions(permission.speak)
				end end
			end
		end

		local companion = client:getChannel(channels[voiceChannel.id].companion)
		if scope == "text" or scope == "both" then
			if user then
				voiceChannel:getPermissionOverwriteFor(member):denyPermissions(permission.sendMessages)

				if channels[voiceChannel.id].companion then
					if companion then
						companion:getPermissionOverwriteFor(member):denyPermissions(permission.sendMessages)
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

				if #roles == 0 then
					voiceChannel:getPermissionOverwriteFor(guild.defaultRole):denyPermissions(permission.sendMessages)
					if companion then
						companion:getPermissionOverwriteFor(guild.defaultRole):denyPermissions(permission.sendMessages)
					end
				else for role in pairs(roles) do
					voiceChannel:getPermissionOverwriteFor(guild:getRole(role)):denyPermissions(permission.sendMessages)
					if companion then
						companion:getPermissionOverwriteFor(guild:getRole(role)):denyPermissions(permission.sendMessages)
					end
				end end
			end
		end

		if user then
			return "Muted mentioned user", okResponse(true, interaction.locale, "muteConfirm", user.mentionString)
		else
			return "Muted all users outside the room", okResponse(true, interaction.locale, "muteAllConfirm")
		end
	end,

	unmute = function (interaction, voiceChannel, scope)
		local user
		if interaction.type == interactionType.applicationCommand then
			scope = scope.name
			user = interaction.option.option.option and interaction.option.option.option.value
		end

		local guild, member, roles = voiceChannel.guild
		if user then
			member = guild:getMember(user)
		else
			roles = channels[voiceChannel.id].parent and channels[voiceChannel.id].parent.roles or {}
		end

		if scope == "voice" or scope == "both" then
			if user then
				voiceChannel:getPermissionOverwriteFor(member):allowPermissions(permission.speak)
			else
				if #roles == 0 then
					voiceChannel:getPermissionOverwriteFor(guild.defaultRole):allowPermissions(permission.speak)
				else for role in pairs(roles) do
					voiceChannel:getPermissionOverwriteFor(guild:getRole(role)):allowPermissions(permission.speak)
				end end
			end
		end

		if scope == "text" or scope == "both" then
			local companion = client:getChannel(channels[voiceChannel.id].companion)
			if user then
				voiceChannel:getPermissionOverwriteFor(member):allowPermissions(permission.sendMessages)
				if companion then
					companion:getPermissionOverwriteFor(member):allowPermissions(permission.sendMessages)
				end
			else
				if #roles == 0 then
					voiceChannel:getPermissionOverwriteFor(guild.defaultRole):allowPermissions(permission.sendMessages)
					if companion then
						companion:getPermissionOverwriteFor(guild.defaultRole):allowPermissions(permission.sendMessages)
					end
				else for role in pairs(roles) do
					voiceChannel:getPermissionOverwriteFor(guild:getRole(role)):allowPermissions(permission.sendMessages)
					if companion then
						companion:getPermissionOverwriteFor(guild:getRole(role)):allowPermissions(permission.sendMessages)
					end
				end end
			end
		end

		if user then
			return "Unmuted mentioned user", okResponse(true, interaction.locale, "unmuteConfirm", user.mentionString)
		else
			return "Unmuted all users outside the room", okResponse(true, interaction.locale, "unmuteAllConfirm")
		end
	end,

	hide = function (interaction, voiceChannel, scope)
		local user
		if interaction.type == interactionType.applicationCommand then
			scope = scope.name
			user = interaction.option.option.option and interaction.option.option.option.value
		end

		local guild, member, roles = voiceChannel.guild
		if user then
			if user == client.user then
				return "Attempt to hide from bot", warningResponse(true, interaction.locale, "shame")
			end
			member = guild:getMember(user)
		else
			roles = channels[voiceChannel.id].parent and channels[voiceChannel.id].parent.roles or {}
		end

		if scope == "voice" or scope == "both" then
			if user then
				voiceChannel:getPermissionOverwriteFor(member):denyPermissions(permission.readMessages)
			else
				for _, member in pairs(voiceChannel.connectedMembers) do
					local po = voiceChannel:getPermissionOverwriteFor(member)
					if not po:getAllowedPermissions():has(permission.readMessages) then
						po:allowPermissions(permission.readMessages)
					end
				end

				if #roles == 0 then
					voiceChannel:getPermissionOverwriteFor(guild.defaultRole):denyPermissions(permission.readMessages)
				else for role in pairs(roles) do
					voiceChannel:getPermissionOverwriteFor(guild:getRole(role)):denyPermissions(permission.readMessages)
				end end
			end
		end

		if scope == "text" or scope == "both" then
			local companion = client:getChannel(channels[voiceChannel.id].companion)
			if companion then
				if user then
					companion:getPermissionOverwriteFor(member):denyPermissions(permission.readMessages)
				else
					for _, member in pairs(voiceChannel.connectedMembers) do
						local po = companion:getPermissionOverwriteFor(member)
						if not po:getAllowedPermissions():has(permission.readMessages) then
							po:allowPermissions(permission.readMessages)
						end
					end

					if #roles == 0 then
						companion:getPermissionOverwriteFor(guild.defaultRole):denyPermissions(permission.readMessages)
					else for role in pairs(roles) do
						companion:getPermissionOverwriteFor(guild:getRole(role)):denyPermissions(permission.readMessages)
					end end
				end
			elseif scope == "text" then
				return "No companion to hide", warningResponse(true, interaction.locale, "hideNoCompanion")
			end
		end

		if user then
			return "Hid the channel from the mentioned user", okResponse(true, interaction.locale, "hideConfirm", user.mentionString)
		else
			return "Hid the channel from all users outside the room", okResponse(true, interaction.locale, "hideAllConfirm")
		end
	end,

	show = function (interaction, voiceChannel, scope)
		local user
		if interaction.type == interactionType.applicationCommand then
			scope = scope.name
			user = interaction.option.option.option and interaction.option.option.option.value
		end

		local guild, member, roles = voiceChannel.guild
		if user then
			member = guild:getMember(user)
		else
			roles = channels[voiceChannel.id].parent and channels[voiceChannel.id].parent.roles or {}
		end

		if scope == "voice" or scope == "both" then
			if user then
				voiceChannel:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
			else
				if #roles == 0 then
					voiceChannel:getPermissionOverwriteFor(guild.defaultRole):allowPermissions(permission.readMessages)
				else for role in pairs(roles) do
					voiceChannel:getPermissionOverwriteFor(guild:getRole(role)):allowPermissions(permission.readMessages)
				end end
			end
		end

		if scope == "text" or scope == "both" then
			local companion = client:getChannel(channels[voiceChannel.id].companion)
			if companion then
				if user then
					voiceChannel:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
				else
					if #roles == 0 then
						companion:getPermissionOverwriteFor(guild.defaultRole):allowPermissions(permission.readMessages)
					else
						for role in pairs(roles) do
							companion:getPermissionOverwriteFor(guild:getRole(role)):allowPermissions(permission.readMessages)
						end
					end
				end
			elseif scope == "text" then
				return "No companion to show", warningResponse(true, interaction.locale, "showNoCompanion")
			end
		end

		if user then
			return "Channel is made visible to the mentioned user", okResponse(true, interaction.locale, "showConfirm", user.mentionString)
		else
			return "Channel is made visible to everyone", okResponse(true, interaction.locale, "showAllConfirm")
		end
	end,

	block = function (interaction, voiceChannel, user)
		if user == client.user then
			return "Attempt to block the bot", warningResponse(true, interaction.locale, "shame")
		end

		local member = voiceChannel.guild:getMember(user)
		voiceChannel:getPermissionOverwriteFor(member):denyPermissions(permission.connect)
		if member.voiceChannel == voiceChannel then
			member:setVoiceChannel()
		end
		return "Blocked the user", okResponse(true, interaction.locale, "blockConfirm", user.mentionString)
	end,

	allow = function (interaction, voiceChannel, user)
		local member = voiceChannel.guild:getMember(user)
		voiceChannel:getPermissionOverwriteFor(member):allowPermissions(permission.connect)

		return "Allowed the user", okResponse(true, interaction.locale, "allowConfirm", user.mentionString)
	end,

	lock = function (interaction, voiceChannel)
		for _, member in pairs(voiceChannel.connectedMembers) do
			local po = voiceChannel:getPermissionOverwriteFor(member)
			if not po:getAllowedPermissions():has(permission.connect) then
				po:allowPermissions(permission.connect)
			end
		end

		local guild = voiceChannel.guild
		local roles = channels[voiceChannel.id].parent and channels[voiceChannel.id].parent.roles or {}

		if #roles == 0 then
			voiceChannel:getPermissionOverwriteFor(guild.defaultRole):denyPermissions(permission.connect)
		else for role in pairs(roles) do
			voiceChannel:getPermissionOverwriteFor(guild:getRole(role)):denyPermissions(permission.connect)
		end end

		return "Locked the room", okResponse(true, interaction.locale, "lockConfirm")
	end,

	unlock = function (interaction, voiceChannel)
		local guild = voiceChannel.guild
		local roles = channels[voiceChannel.id].parent and channels[voiceChannel.id].parent.roles or {}

		if #roles == 0 then
			voiceChannel:getPermissionOverwriteFor(guild.defaultRole):allowPermissions(permission.connect)
		else for role in pairs(roles) do
			voiceChannel:getPermissionOverwriteFor(guild:getRole(role)):allowPermissions(permission.connect)
		end end

		return "Unlocked the room", okResponse(true, interaction.locale, "unlockConfirm")
	end,

	invite = function (interaction, voiceChannel, user)
		local tryReservation = channels[voiceChannel.id].host == interaction.user.id and
			checkHostPermissions(interaction.member or voiceChannel.guild:getMember(interaction.user), voiceChannel, "moderate")
		local invite = voiceChannel:createInvite()

		if not invite then
			return "Bot isn't permitted to create invites", warningResponse(true, interaction.locale, "inviteError")
		end

		if not user then
			return "Created invite in room", okResponse(true, interaction.locale, "inviteCreated", invite.code)
		end

		if not user:getPrivateChannel() then
			return "Can't contact user", warningResponse(true, interaction.locale, "noDMs", invite.code)
		end

		user:getPrivateChannel():sendf(localeHandler(interaction.locale, "inviteText"), interaction.user.name, voiceChannel.name, invite.code)

		if tryReservation then
			voiceChannel:getPermissionOverwriteFor(voiceChannel.guild:getMember(user)):allowPermissions(permission.readMessages, permission.connect, permission.speak)
		end
		return "Sent invite to mentioned user", okResponse(true, interaction.locale, "inviteConfirm", user.mentionString)
	end,

	password = function (interaction, voiceChannel, password)
		channels[voiceChannel.id]:setPassword(password)

		if password then
			return "New password set", okResponse(true, interaction.locale, "passwordConfirm", password)
		else
			return "Password reset", okResponse(true, interaction.locale, "passwordReset")
		end
	end,

	passwordinit = function (interaction)	-- not exposed, access via componentInteraction
		interaction:createModal("room_passwordcheck", localeHandler(interaction.locale, "passwordEnter"), passwordModal(interaction))
		return "Created password modal"
	end,

	passwordcheck = function (interaction, voiceChannel)	-- not exposed, access via modalInteraction
		local channelData = channels[voiceChannel.id]
		local channel = client:getChannel(channelData and channelData.parent.id)

		if not channel then
			if channelData and channelData.parentType == 3 then voiceChannel:delete() end
			return "No parent channel", warningResponse(true, interaction.locale, "passwordNoChannel")
		elseif interaction.components[1].components[1].value == channelData.parent.password then
			local member = voiceChannel.guild:getMember(interaction.user)

			-- sendMessages is used as an indication of blocklist, to not conflict with password flow
			if channel:getPermissionOverwriteFor(member):getDeniedPermissions():has(permission.sendMessages) then
				if channelData and channelData.parentType == 3 then voiceChannel:delete() end
				return "User is banned", warningResponse(true, interaction.locale, "passwordBanned")
			end

			channel:getPermissionOverwriteFor(member):allowPermissions(permission.connect)
			member:setVoiceChannel(channel.id)
			return "Successfull password check", okResponse(true, interaction.locale, "passwordSuccess")
		else
			return "Failed password check", warningResponse(true, interaction.locale, "passwordFailure")
		end
	end,

	widget = function (interaction, voiceChannel, argument)	-- not exposed, access via componentInteraction
		local action, scope = argument:match("^(.-)_(.-)$")
		if not action then action = argument end
		interaction:deferReply(true)

		local log, response = subcommands[action](interaction, voiceChannel, scope)
		interaction:updateReply(response)

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
		return "User not in room", warningResponse(true, interaction.locale, "notInRoom")
	end

	local voiceChannel = member.voiceChannel
	if subcommand == "view" then
		return "Sent room info", roomInfoResponse(true, interaction.locale, voiceChannel)
	end

	if noAdmin[subcommand] or member:hasPermission(voiceChannel, permission.administrator) or config.owners[interaction.user.id] then
		return subcommands[subcommand](interaction, voiceChannel, argument)
	elseif channels[voiceChannel.id].host == interaction.user.id then
		if checkHostPermissions(member, voiceChannel, subcommand) then
			return subcommands[subcommand](interaction, voiceChannel, argument)
		end
		return "Insufficient permissions", warningResponse(true, interaction.locale, "badHostPermission")
	end
	return "Not a host", warningResponse(true, interaction.locale, "notHost")
end
