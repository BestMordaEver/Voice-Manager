local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

return {
		name = "companion",
		description = "Configure lobby companion settings",
		contexts = {contextType.guild},
		options = {
			{
				name = "view",
				description = "Show lobbies with enabled companion chats",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be viewed",
						type = commandOptionType.channel,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "enable",
				description = "Enable companion chats for selected lobby",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "Selected lobby",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "disable",
				description = "Disable companion chats for selected lobby",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "Selected lobby",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "category",
				description = "Select a category in which a companion chat will be created",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "category",
						description = "A category in which a companion chat will be created",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.category
						}
					}
				}
			},
			{
				name = "name",
				description = "Configure what name a chat will have when it's created",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "name",
						description = "Name a chat will have when it's created",
						type = commandOptionType.string,
						required = true
					}
				}
			},
			{
				name = "greeting",
				description = "Configure a message that will be automatically sent to chat when it's created",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "greeting",
						description = "Skip this to enter multiline greeting",
						type = commandOptionType.string
					}
				}
			},
			{
				name = "log",
				description = "Enable chat logging. Logs will be sent as files to a channel of your choosing",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "channel",
						description = "A channel where logs will be sent",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.text
						}
					}
				}
			}
		}
	}