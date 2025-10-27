local client = require "client"

local lobbies = require "storage/lobbies"

local okResponse = require "response/ok"
local warningResponse = require "response/warning"

local channelType = require "discordia".enums.channelType
local insert, concat = table.insert, table.concat

local modes = {
    username = function (member) return member.user.name end,
    tag = function (member) return member.user.tag end,
    nickname = function (member) return member.name end,
    mention = function (member) return member.user.mentionString end,
    id = function (member) return member.user.id end
}

local commands = {
    print = function (interaction, channels)

		local options = interaction.options
        local separator = options.separator and options.separator.value or " "
        local extractor = modes[options.print_as and options.print_as.value or "mention"]
        local names = {}

        for _, channel in ipairs(channels) do
            for _, member in pairs(channel.connectedMembers) do
                insert(names, extractor(member))
            end
        end

		if #names == 0 then
			return "No users found", warningResponse(true, interaction.locale, "noUsers")
		end

        return "Sent names list", {ephemeral = true, file = {"users.txt", concat(names, separator)}}
    end,

    give = function (interaction, channels)
        local role, count = interaction.options.role.value, 0
        for _, channel in ipairs(channels) do
            for _, member in pairs(channel.connectedMembers) do
                if member:addRole(role) then
                    count = count + 1
                end
            end
        end
        return "Added roles to users", okResponse(true, interaction.locale, "usersRolesAdded", count)

    end,

    remove = function (interaction, channels)
        local role, count = interaction.options.role.value, 0
        for _, channel in ipairs(channels) do
            for _, member in pairs(channel.connectedMembers) do
                if member:removeRole(role) then
                    count = count + 1
                end
            end
        end
        return "Removed roles from users", okResponse(true, interaction.locale, "usersRolesRemoved", count)
    end
}

return function (interaction, subcommand)
    local channels = {}
    local channel = interaction.options.channel.value
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
        return "No channels to query", warningResponse(true, interaction.locale, "noChildChannels")
    end

    return commands[subcommand](interaction, channels)
end