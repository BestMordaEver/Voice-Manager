local client = require "client"

local channels = require "storage/channels"

local availableCommands = require "response/availableCommands"

local enums = require "discordia".enums
local permission = enums.permission
local overwriteType = enums.overwriteType

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/localeHandler"
local response = require "response/response"

local format = string.format

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

local header = "**%s**"
local headerAndNL = "**%s**\n%s"
local function liner (locale, channel, rolePO, type, perm)
	local row = {
		type = componentType.textDisplay
	}

	if rolePO:getDeniedPermissions():has(perm) then
		local line
		local POs = channel.permissionOverwrites:toArray(function (po) return po.type == overwriteType.member and po:getAllowedPermissions():has(perm) end)
		if #POs ~= 0 then
			local mentions = {}
			table.insert(mentions, localeHandler(locale, lines[type][perm].deniedExceptions))
			for _, po in pairs(POs) do
				table.insert(mentions, po:getObject().user.mentionString)
			end
			line = table.concat(line, " ")
		end

		row.content = #POs == 0 and
			format(header, localeHandler(locale, lines[type][perm].denied))
		or
			format(headerAndNL, localeHandler(locale, lines[type][perm].denied), line)
	else
		local line
		local POs = channel.permissionOverwrites:toArray(function (po) return po.type == overwriteType.member and po:getDeniedPermissions():has(perm) end)
		if #POs ~= 0 then
			local mentions = {}
			table.insert(mentions, locale(mentions, lines[type][perm].allowedExceptions))
			for _, po in pairs(POs) do
				table.insert(mentions, po:getObject().user.mentionString)
			end
			line = table.concat(line, " ")
		end

		row.content = #POs == 0 and
			format(header, localeHandler(locale, lines[type][perm].allowed))
		or
			format(headerAndNL, localeHandler(locale, lines[type][perm].allowed), line)
	end
	return row
end

---@overload fun(ephemeral : boolean, locale : localeName, room : GuildVoiceChannel) : table
local roomInfo = response("roomInfo", response.colors.blurple, function (locale, room)
	local companion = client:getChannel(channels[room.id].companion)
	local role = channels[room.id].parent and client:getRole(channels[room.id].parent.roles:random()) or room.guild.defaultRole
	local roomPO = room:getPermissionOverwriteFor(role)
	local chatPO = companion and companion:getPermissionOverwriteFor(role)

	local components = {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "roomInfoTitle")
		},
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "roomInfoHost", client:getUser(channels[room.id].host).mentionString)
		},
		{
			type = componentType.textDisplay,
			content = table.concat({
				liner(locale, room, roomPO, "voice", permission.readMessages),
				liner(locale, room, roomPO, "voice", permission.connect),
				liner(locale, room, roomPO, "voice", permission.speak),
				liner(locale, room, roomPO, "voice", permission.sendMessages),
				companion and liner(locale, companion, chatPO, "text", permission.readMessages),
				companion and liner(locale, companion, chatPO, "text", permission.sendMessages),
				localeHandler(locale, "roomInfoCommands", availableCommands(room))
			}, "\n")
		}
	}

	return components
end)

return roomInfo