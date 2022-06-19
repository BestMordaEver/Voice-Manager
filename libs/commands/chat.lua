local client = require "client"
local locale = require "locale"
local config = require "config"

local channels = require "storage".channels

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"
local chatInfoEmbed = require "embeds/chatInfo"
local greetingEmbed = require "embeds/greeting"

local hostPermissionCheck = require "funcs/hostPermissionCheck"
local templateInterpreter = require "funcs/templateInterpreter"
local ratelimiter = require "utils/ratelimiter"

local permission = require "discordia".enums.permission
local overwriteType = require "discordia".enums.overwriteType

ratelimiter("companionName", 2, 600)

local function reprivilegify (voiceChannel, chat)
	for _, permissionOverwrite in pairs(chat.permissionOverwrites) do
		if permissionOverwrite.type == overwriteType.member and
			permissionOverwrite:getObject().voiceChannel ~= voiceChannel and
			permissionOverwrite:getObject() ~= voiceChannel.guild.me then

			permissionOverwrite:delete()
		end
	end

	for _, member in pairs(voiceChannel.connectedMembers) do
		chat:getPermissionOverwriteFor(member):allowPermissions(permission.connect, permission.readMessages)
	end
end

local subcommands
subcommands = {
	rename = function (interaction, chat, name)
		local limit, retryIn = ratelimiter:limit("companionName", chat.id)
		local success, err

		if limit == -1 then
			return "Ratelimit reached", warningEmbed(locale.ratelimitReached:format(retryIn))
		else
			local member = interaction.member or chat.guild:getMember(interaction.user)
			local channelData = channels[member.voiceChannel.id]
			local parent = channelData.parent

			if parent and parent.companionTemplate and parent.companionTemplate:match("%%rename%%") then
				success, err = chat:setName(templateInterpreter(parent.companionTemplate, member, channelData.position, name):discordify())
			else
				success, err = chat:setName(name:discordify())
			end
		end

		if success then
			return "Successfully changed chat name", okEmbed(locale.nameConfirm:format(chat.name).."\n"..locale[limit == 0 and "ratelimitReached" or "ratelimitRemaining"]:format(retryIn))
		else
			return "Couldn't change chat name: "..err, warningEmbed(locale.renameError)
		end
	end,

	hide = function (interaction, chat, user)
		if user == client.user then
			return "Attempt to block the bot", warningEmbed(locale.shame)
		end
		chat:getPermissionOverwriteFor(chat.guild:getMember(user)):denyPermissions(permission.readMessages)
		return "Hidden the chat from user", okEmbed(locale.hideConfirm:format(user.mentionString))
	end,

	show = function (interaction, chat, user)
		chat:getPermissionOverwriteFor(chat.guild:getMember(user)):allowPermissions(permission.readMessages)
		return "Made the chat visible to user", okEmbed(locale.showConfirm:format(user.mentionString))
	end,

	mute = function (interaction, chat, user)
		chat:getPermissionOverwriteFor(chat.guild:getMember(user)):denyPermissions(permission.sendMessages)
		return "Muted mentioned members", okEmbed(locale.muteConfirm:format(user.mentionString))
	end,

	unmute = function (interaction, chat, user)
		chat:getPermissionOverwriteFor(chat.guild:getMember(user)):clearPermissions(permission.sendMessages)
		return "Unmuted mentioned members", okEmbed(locale.unmuteConfirm:format(user.mentionString))
	end,

	clear = function (interaction, chat, amount)
		local trueAmount, first = 0, chat:getFirstMessage()
		if first then
			if amount and amount > 0 then
				repeat
					local bulk = chat:getMessages(amount > 100 and 100 or amount)
					if bulk:get(first.id) then bulk = chat:getMessagesAfter(first, 100) end
					if #bulk == 0 then break end
					trueAmount = trueAmount + #bulk
					chat:bulkDelete(bulk)
					amount = amount - 100
				until amount <= 0
			else
				repeat
					local bulk = chat:getMessagesAfter(first, 100)
					if #bulk == 0 then
						if first.author ~= client.user then
							chat:bulkDelete({first})
							trueAmount = trueAmount + 1
						end
						break
					else
						chat:bulkDelete(bulk)
						trueAmount = trueAmount + #bulk
					end
				until false
			end
		end

		return "Successfully cleared "..trueAmount.." messages", okEmbed(locale.clearConfirm:format(trueAmount))
	end,

	save = function (interaction, chat, amount)
		return "unfinished", warningEmbed(locale.unfinishedCommand)
	end,

	widget = function (interaction, chat)	-- not exposed, access via componentInteraction
		local guild, channel, argument, log = chat.guild, interaction.member.voiceChannel, interaction.values[1]
		local parent = channels[channel.id].parent

		if argument == "lock" then
			reprivilegify(channel, chat)
			local ov = chat:getPermissionOverwriteFor(parent and guild:getRole(parent.role) or guild.defaultRole)
			ov:denyPermissions(permission.sendMessages)
			ov:clearPermissions(permission.readMessages)
			log = "Chat is locked"
		elseif argument == "hide" then
			reprivilegify(channel, chat)
			chat:getPermissionOverwriteFor(parent and guild:getRole(parent.role) or guild.defaultRole):denyPermissions(permission.readMessages)
			log = "Chat is hidden"
		elseif argument == "open" then
			chat:getPermissionOverwriteFor(parent and guild:getRole(parent.role) or guild.defaultRole):clearPermissions(permission.sendMessages, permission.readMessages)
			log = "Opened the chat"
		end

		interaction:deferUpdate()
		return log
	end
}

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
	local chat = client:getChannel(channels[voiceChannel.id].companion) or (voiceChannel.textEnabled and voiceChannel)
	if not chat then
		return "Room doesn't have a chat", warningEmbed(locale.noCompanion)
	end

	if subcommand == "view" then
		return "Sent chat info", chatInfoEmbed(voiceChannel)
	end

	if member:hasPermission(chat, permission.administrator) or config.owners[interaction.user.id] then
		return subcommands[subcommand](interaction, chat, argument)
	elseif channels[voiceChannel.id].host == interaction.user.id then
		if hostPermissionCheck(member, voiceChannel, subcommand) then
			return subcommands[subcommand](interaction, chat, argument)
		end
		return "Insufficient permissions", warningEmbed(locale.badHostPermission)
	end
	return "Not a host", warningEmbed(locale.notHost)
end
