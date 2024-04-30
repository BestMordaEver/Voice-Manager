local enums = require "discordia".enums
local locale = require "locale"
local config = require "config"
local client = require "client"

local channels = require "handlers/storageHandler".channels

local permission = enums.permission
local channelType = enums.channelType

local channelHandler = {}

channelHandler.adjustPermissions = function (channel, newHost, oldHost)
    local lobbyData = channels[channel.id].parent

    local perms, isAdmin, needsManage =
    lobbyData.permissions:toDiscordia(),
    channel.guild.me:getPermissions():has(permission.administrator),
    lobbyData.permissions.bitfield:has(lobbyData.permissions.bits.moderate)

    if #perms ~= 0 then
		channel:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
		if oldHost then channel:getPermissionOverwriteFor(oldHost):clearPermissions(table.unpack(perms)) end

        if isAdmin and needsManage then
            channel:getPermissionOverwriteFor(newHost):allowPermissions(permission.manageRoles)
            if oldHost then channel:getPermissionOverwriteFor(oldHost):clearPermissions(permission.manageRoles) end
        end

        if not channel or not channels[channel.id] then return end
        local companion = client:getChannel(channels[channel.id].companion)
        if companion then
			companion:getPermissionOverwriteFor(newHost):allowPermissions(table.unpack(perms))
			if oldHost then companion:getPermissionOverwriteFor(oldHost):clearPermissions(table.unpack(perms)) end

            if isAdmin and needsManage then
                companion:getPermissionOverwriteFor(newHost):allowPermissions(permission.manageRoles)
                if oldHost then companion:getPermissionOverwriteFor(oldHost):clearPermissions(permission.manageRoles) end
            end
        end
    end
end

local requiredPerms = {
	bitrate = {manage = true},
	rename = {manage = true},
	resize = {manage = true},
	kick = {moderate = true},
	mute = {moderate = true},
	unmute = {moderate = true, mute = true},
	hide = {moderate = true},
	show = {moderate = true, hide = true},
	lock = {moderate = true},
	unlock = {moderate = true, lock = true},
	block = {moderate = true, lock = true},
	unblock = {moderate = true, lock = true},
	clear = {manage = true},
	password = {moderate = true}
}

channelHandler.checkHostPermissions = function (member, channel, permissionName)
	local permissions = channels[channel.id].parent.permissions
	if not permissions then return false end
	if channels[channel.id].host ~= member.user.id then return false end

	if permissions:has(permissionName) then return true end

	for _, subpermissions in pairs(requiredPerms) do
		for permission, _ in pairs(subpermissions) do
			if permissions:has(permission) then return true end
		end
	end

	return false
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
		(a.category == b.category and
			((a.type ~= channelType.voice and a.type ~= channelType.stageVoice and (b.type == channelType.voice or b.type == channelType.stageVoice)) or
			a.position < b.position or a.createdAt < b.createdAt))
end

channelHandler.handleTemplate = function (template, member, position, replacement)
	local uname = member.user.name
	local nickname = member.nickname or uname
	local game =
		member.playing and member.playing.name or
		(member.streaming and member.streaming.name) or
		(member.competing and member.competing.name) or
		template:match("%%game%((.-)%)%%") or "no game"
	local standin = template:match("%%rename%((.-)%)%%") or ""

	template = template:gsub("%%game%(.-%)%%", game:demagic()):gsub("%%rename%(.-%)%%", standin:demagic())

	local rt = {
		nickname = nickname,
		name = uname,
		tag = member.user.username,
		game = game,
		counter = position,
		["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
		["name's"] = uname .. (uname:sub(-1,-1) == "s" and "'" or "'s"),
		rename = replacement or standin
	}
	return template:gsub("%%(.-)%%", rt), nil
end

return channelHandler