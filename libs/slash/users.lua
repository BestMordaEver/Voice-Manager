local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

return {
    name = "users",
    description = "Miscellaneous moderation and helper commands",
    contexts = {contextType.guild},
    options = {
        {
            name = "print",
            description = "Create a list of users that are in the channel",
            type = commandOptionType.subcommand,
            options = {
                {
                    name = "channel",
                    description = "Channels to be queried",
                    type = commandOptionType.channel,
                    required = true,
                    channel_types = {
                        channelType.voice,
                        channelType.stageVoice,
                        channelType.category
                    }
                },
                {
                    name = "print_as",
                    description = "Output mode, default is mention (will never ping)",
                    type = commandOptionType.string,
                    choices = {
                        {
                            name = "username",
                            value = "username"
                        },
                        {
                            name = "tag",
                            value = "tag"
                        },
                        {
                            name = "nickname",
                            value = "nickname"
                        },
                        {
                            name = "mention",
                            value = "mention"
                        },
                        {
                            name = "id",
                            value = "id"
                        }
                    }
                },
                {
                    name = "separator",
                    description = "Separator string that will be put between entries of a list, default is space",
                    type = commandOptionType.string
                }
            }
        },
        {
            name = "give",
            description = "Give users in a channel or lobby rooms a role",
            type = commandOptionType.subcommand,
            options = {
                {
                    name = "channel",
                    description = "Channel or lobby to be queried",
                    type = commandOptionType.channel,
                    required = true,
                    channel_types = {
                        channelType.voice,
                        channelType.stageVoice,
                        channelType.category
                    }
                },
                {
                    name = "role",
                    description = "Role to be given out",
                    type = commandOptionType.role,
                    required = true
                }
            }
        },
        {
            name = "remove",
            description = "Give users in a channel or lobby rooms a role",
            type = commandOptionType.subcommand,
            options = {
                {
                    name = "channel",
                    description = "Channel or lobby to be queried",
                    type = commandOptionType.channel,
                    required = true,
                    channel_types = {
                        channelType.voice,
                        channelType.stageVoice,
                        channelType.category
                    }
                },
                {
                    name = "role",
                    description = "Role to be given out",
                    type = commandOptionType.role,
                    required = true
                }
            }
        }
    }
}