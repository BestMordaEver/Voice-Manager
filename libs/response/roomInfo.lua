local client = require "client"
local locale = require "locale/runtime/localeHandler"
local embed = require "response/embed"

local channels = require "storage/channels"

local availableCommands = require "response/availableCommands"

local enums = require "discordia".enums
local permission = enums.permission
local overwriteType = enums.overwriteType
local blurple = embed.colors.blurple

local lines = {
	voice = {
		[permission.readMessages] = {
			allowed = "roomInfoVisible",
			allowedExceptions = "roomInfoVisibleExceptions",
			denied = "roomInfoInvisible",
			deniedExceptions = "roomInfoInvisibleExceptions"
		},
		[permission.connect] = {
			allowed = "roomInfoPublic",
			allowedExceptions = "roomInfoPublicExceptions",
			denied = "roomInfoPrivate",
			deniedExceptions = "roomInfoPrivateExceptions"
		},
		[permission.speak] = {
			allowed = "roomInfoVocal",
			allowedExceptions = "roomInfoVocalExceptions",
			denied = "roomInfoSilent",
			deniedExceptions = "roomInfoSilentExceptions"
		},
		[permission.sendMessages] = {
			allowed = "roomInfoWriting",
			allowedExceptions = "roomInfoWritingExceptions",
			denied = "roomInfoMuted",
			deniedExceptions = "roomInfoMutedExceptions"
		}
	},
	text = {
		[permission.readMessages] = {
			allowed = "chatInfoVisible",
			allowedExceptions = "chatInfoVisibleExceptions",
			denied = "chatInfoInvisible",
			deniedExceptions = "chatInfoInvisibleExceptions"
		},
		[permission.sendMessages] = {
			allowed = "chatInfoWriting",
			allowedExceptions = "chatInfoWritingExceptions",
			denied = "chatInfoMuted",
			deniedExceptions = "chatInfoMutedExceptions"
		}
	}
}

local function liner (loc, channel, rolePO, type, perm)
	local field = {value = ""}
	if rolePO:getDeniedPermissions():has(perm) then
		field.name = locale(loc, lines[type][perm].denied)
		local POs = channel.permissionOverwrites:toArray(function (po) return po.type == overwriteType.member and po:getAllowedPermissions():has(perm) end)
		if #POs ~= 0 then
			local line = {}
			table.insert(line, locale(loc, lines[type][perm].deniedExceptions))
			for _, po in pairs(POs) do
				table.insert(line, po:getObject().user.mentionString)
			end
			field.value = table.concat(line, " ")
		end
	else
		field.name = locale(loc, lines[type][perm].allowed)
		local POs = channel.permissionOverwrites:toArray(function (po) return po.type == overwriteType.member and po:getDeniedPermissions():has(perm) end)
		if #POs ~= 0 then
			local line = {}
			table.insert(line, locale(loc, lines[type][perm].allowedExceptions))
			for _, po in pairs(POs) do
				table.insert(line, po:getObject().user.mentionString)
			end
		end
	end
	return field
end

return embed("roomInfo", function (interaction, room, ephemeral)
	local companion = client:getChannel(channels[room.id].companion)
	local role = channels[room.id].parent and client:getRole(channels[room.id].parent.roles:random()) or room.guild.defaultRole
	local roomPO = room:getPermissionOverwriteFor(role)
	local chatPO = companion and companion:getPermissionOverwriteFor(role)
	local loc = interaction.locale

	local fields = {
		liner(loc, room, roomPO, "voice", permission.readMessages),
		liner(loc, room, roomPO, "voice", permission.connect),
		liner(loc, room, roomPO, "voice", permission.speak),
		liner(loc, room, roomPO, "voice", permission.sendMessages),
		companion and liner(loc, companion, chatPO, "text", permission.readMessages),
		companion and liner(loc, companion, chatPO, "text", permission.sendMessages)
	}

	table.insert(fields, {name = locale(loc, "roomInfoCommands"), value = availableCommands(room)})

	return {embeds = {{
		title = locale(loc, "roomInfoTitle", room.name),
		color = blurple,
		description = locale(loc, "roomInfoHost") .. client:getUser(channels[room.id].host).mentionString .. "\n",
		fields = fields,
	}}, ephemeral = ephemeral}
end)