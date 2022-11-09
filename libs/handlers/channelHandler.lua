local discordia = require "discordia"
local client = require "client"
local channels = require "storage".channels

local permission = discordia.enums.permission

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

return channelHandler