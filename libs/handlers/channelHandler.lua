local discordia = require "discordia"
local logger = require "logger"
local locale = require "locale"
local config = require "config"
local client = require "client"

local channels = require "handlers/storageHandler".channels

local permission = discordia.enums.permission
local overwriteType = discordia.enums.overwriteType

local channelHandler = {}

channelHandler.adjustPermissions = function (channel, newHost, oldHost)
    local lobbyData = channels[channel.id].parent

    local perms, isAdmin, needsManage =
    lobbyData.permissions:toDiscordia(),
    channel.guild.me:getPermissions():has(permission.administrator),
    lobbyData.permissions.bitfield:has(lobbyData.permissions.bits.moderate)

    if #perms ~= 0 then
        if isAdmin or channel.guild.me:getPermissions(channel):has(table.unpack(perms)) then
            channel:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
            if oldHost then channel:getPermissionOverwriteFor(oldHost):clearPermissions(table.unpack(perms)) end
        end

        if isAdmin and needsManage then
            channel:getPermissionOverwriteFor(newHost):allowPermissions(permission.manageRoles)
            if oldHost then channel:getPermissionOverwriteFor(oldHost):clearPermissions(permission.manageRoles) end
        end

        if not channel or not channels[channel.id] then return end
        local companion = client:getChannel(channels[channel.id].companion)
        if companion then
            if isAdmin or channel.guild.me:getPermissions(companion):has(table.unpack(perms)) then
                companion:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
                if oldHost then companion:getPermissionOverwriteFor(oldHost):clearPermissions(table.unpack(perms)) end
            end

            if isAdmin and needsManage then
                companion:getPermissionOverwriteFor(newHost):allowPermissions(permission.manageRoles)
                if oldHost then companion:getPermissionOverwriteFor(oldHost):clearPermissions(permission.manageRoles) end
            end
        end
    end
end

local requiredPerms = {
	bitrate = "manage",
	blocklist = "moderate",
	kick = "moderate",
	mute = "moderate",
	rename = "manage",
	reservations = "moderate",
	resize = "manage",
	unmute = "moderate",
	clear = "manage",
	lock = "moderate",
	password = "moderate",
	widget = "moderate",
}

channelHandler.checkHostPermissions = function (member, channel, permissionName)
	local permissions = channels[channel.id].parent.permissions

	return permissions and channels[channel.id].host == member.user.id and (permissions:has(permissionName) or permissions:has(requiredPerms[permissionName]))
end

channelHandler.checkPermissions = function (interaction, channel)
	if not interaction.guild.me:hasPermission(channel, permission.manageChannels) then
		return false, "Bad bot permissions", locale.badBotPermissions
	end

	if config.owners[interaction.user.id] then return true end

	if not (
		channel and
		channel.permissions and
		channel.permissions:has(permission.manageChannels) or
			(interaction.member or channel.guild:getMember(interaction.user)):hasPermission(channel, permission.manageChannels))then
		return false, "Bad user permissions", locale.badUserPermissions
	end

	return true
end

-- returns channels in the same order they are presented in the app
-- https://imgur.com/a/hRWM73c
channelHandler.truePositionSort = function (a, b)
	return (not a.category and b.category) or
		(a.category and b.category and a.category.position < b.category.position) or
		(a.category == b.category and a.position < b.position)
end

channelHandler.enforceReservations = function (channel)
	local reservations = channel.userLimit == 0 and 0 or #channel.permissionOverwrites:toArray(function (permissionOverwrite)
		return permissionOverwrite:getObject() ~= channel.guild.me and
			permissionOverwrite.type == overwriteType.member and
			permissionOverwrite:getObject().voiceChannel ~= channel and
			permissionOverwrite:getAllowedPermissions():has(permission.connect)
	end)

	local parent = channels[channel.id].parent
	local roleOverwrite = channel:getPermissionOverwriteFor(parent and channel.guild:getRole(parent.role) or channel.guild.defaultRole)

	if reservations ~= 0 and reservations >= channel.userLimit - #channel.connectedMembers then
		if not roleOverwrite:getDeniedPermissions():has(permission.connect) then
			logger:log(4, "GUILD %s ROOM %s: locked", channel.guild.id, channel.id)
			roleOverwrite:denyPermissions(permission.connect)
		end
	else
		if roleOverwrite:getDeniedPermissions():has(permission.connect) then
			logger:log(4, "GUILD %s ROOM %s: unlocked", channel.guild.id, channel.id)
			roleOverwrite:clearPermissions(permission.connect)
		end
	end
end

channelHandler.handleTemplate = function (template, member, position, replacement)
	local uname = member.user.globalName or member.user.name
	local nickname = member.nickname or uname
	local game =
		member.playing and member.playing.name or
		(member.streaming and member.streaming.name) or
		(member.competing and member.competing.name) or
		template:match("%%game%((.-)%)%%") or "no game"

	template = template:gsub("%%game%(.-%)%%", game:demagic())

	local rt = {
		nickname = nickname,
		name = uname,
		tag = member.user.discriminator == "0" and member.user.name or member.user.tag,
		game = game,
		counter = position,
		["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
		["name's"] = uname .. (uname:sub(-1,-1) == "s" and "'" or "'s"),
		rename = replacement or ""
	}
	return template:gsub("%%(.-)%%", rt), nil
end

return channelHandler