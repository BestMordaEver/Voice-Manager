local client = require "client"
local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local channels = require "handlers/storageHandler".channels

local availableCommands = require "embeds/availableCommands"

local enums = require "discordia".enums
local permission = enums.permission
local overwriteType = enums.overwriteType
local blurple = embedHandler.colors.blurple

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

local function liner (channel, rolePO, type, perm)
	local field = {value = ""}
	if rolePO:getDeniedPermissions():has(perm) then
		field.name = locale[lines[type][perm].denied]
		local POs = channel.permissionOverwrites:toArray(function (po) return po.type == overwriteType.member and po:getAllowedPermissions():has(perm) end)
		if #POs ~= 0 then
			local line = {}
			table.insert(line, locale[lines[type][perm].deniedExceptions])
			for _, po in pairs(POs) do
				table.insert(line, po:getObject().user.mentionString)
			end
			field.value = table.concat(line, " ")
		end
	else
		field.name = locale[lines[type][perm].allowed]
		local POs = channel.permissionOverwrites:toArray(function (po) return po.type == overwriteType.member and po:getDeniedPermissions():has(perm) end)
		if #POs ~= 0 then
			local line = {}
			table.insert(line, locale[lines[type][perm].allowedExceptions])
			for _, po in pairs(POs) do
				table.insert(line, po:getObject().user.mentionString)
			end
		end
	end
	return field
end

return embedHandler("roomInfo", function (room, ephemeral)
	local companion = client:getChannel(channels[room.id].companion)
	local role = channels[room.id].parent and client:getRole(channels[room.id].parent.role) or room.guild.defaultRole
	local roomPO = room:getPermissionOverwriteFor(role)
	local chatPO = companion and companion:getPermissionOverwriteFor(role)

	local fields = {
		liner(room, roomPO, "voice", permission.readMessages),
		liner(room, roomPO, "voice", permission.connect),
		liner(room, roomPO, "voice", permission.speak),
		liner(room, roomPO, "voice", permission.sendMessages),
		companion and companion ~= room and liner(companion, chatPO, "text", permission.readMessages),
		companion and companion ~= room and liner(companion, chatPO, "text", permission.sendMessages)
	}

	table.insert(fields, {name = locale.roomInfoCommands, value = availableCommands(room)})

	return {embeds = {{
		title = locale.roomInfoTitle:format(room.name),
		color = blurple,
		description = locale.roomInfoHost .. client:getUser(channels[room.id].host).mentionString .. "\n",
		fields = fields,
	}}, ephemeral = ephemeral}
end)