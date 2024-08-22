local client = require "client"
local locale = require "locale/runtime/localeHandler"

local lobbies = require "storage/lobbies"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"

local channelType = require "discordia".enums.channelType
local insert = table.insert

local modes = {
    username = function (member) return member.user.name end,
    tag = function (member) return member.user.tag end,
    nickname = function (member) return member.name end,
    mention = function (member) return member.user.mentionString end,
    id = function (member) return member.user.id end
}

local commands = {
    print = function (interaction, channels, options)
        local names = {}
        do
            local separator, extractor = options.separator and options.separator.value or " ", modes[options.print_as and options.print_as.value or "mention"]

            for _, channel in ipairs(channels) do
                for _, member in pairs(channel.connectedMembers) do
                    insert(names, extractor(member))
                end
            end

            names = table.concat(names, separator)
            if #names == 0 then names = locale(interaction.locale, "none") end
        end

        local embeds, index, len = {}, 1, #names
        if len > 40960 then   -- 4096 chars per embed, 10 embeds per message
            repeat
                insert(embeds, {description = names:sub(index, index + 4095)})
                index = index + 4096
                if #embeds == 10 then
                    interaction:followup {ephemeral = true, embeds = embeds}
                    embeds = {}
                end
            until index >= len
            return "Sent names list", okEmbed(interaction, "usersSent")
        end

        repeat
            insert(embeds, {description = names:sub(index, index + 4095)})
            index = index + 4096
        until index >= len
        return "Sent names list", {embeds = embeds}

    end,

    give = function (interaction, channels, options)
        local role, count = options.role.value, 0
        for _, channel in ipairs(channels) do
            for _, member in pairs(channel.connectedMembers) do
                if member:addRole(role) then
                    count = count + 1
                end
            end
        end
        return "Added roles to users", okEmbed(interaction, "usersRolesAdded", count)

    end,

    remove = function (interaction, channels, options)
        local role, count = options.role.value, 0
        for _, channel in ipairs(channels) do
            for _, member in pairs(channel.connectedMembers) do
                if member:removeRole(role) then
                    count = count + 1
                end
            end
        end
        return "Removed roles from users", okEmbed(interaction, "usersRolesRemoved", count)
    end
}

return function (interaction, subcommand)
    local channels, options = {}, interaction.option.options

    local channel = options.channel.value
    local lobbyData = lobbies[channel.id]

    if lobbyData then
        local target = client:getChannel(lobbyData.target)
        if lobbyData.isMatchmaking and (not target or target.type == channelType.category) then
            for _, channel in pairs((target or channel.category or channel.guild).voiceChannels) do
                insert(channels, channel)
            end
        else
            while lobbyData.isMatchmaking do
                lobbyData = lobbies[lobbyData.target]
            end

            for _,channelData in pairs(lobbyData.children) do
                insert(channels, client:getChannel(channelData.id))
            end
        end
    elseif channel.type == channelType.category then
        for _, channel in pairs(channel.voiceChannels) do
            insert(channels, channel)
        end
    else
        channels = {channel}
    end

    if #channels == 0 then
        return "No channels to query", warningEmbed(interaction, "noChildChannels")
    end

    return commands[subcommand](interaction, channels, options)
end