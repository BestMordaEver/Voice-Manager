local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

return {
	name = "matchmaking",
	description = "Configure matchmaking lobby settings",
	contexts = {contextType.guild},
	options = {
		{
			name = "view",
			description = "Show registered matchmaking lobbies",
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
			name = "add",
			description = "Register a new matchmaking lobby",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "channel",
					description = "A channel to be registered",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = "remove",
			description = "Remove an existing matchmaking lobby",
			type = commandOptionType.subcommand,
			options = {
				{
					name = "lobby",
					description = "A matchmaking lobby to be removed",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice
					}
				}
			}
		},
		{
			name = "target",
			description = "Select a target for matchmaking pool",
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
					name = "target",
					description = "A target for matchmaking pool",
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice, channelType.category
					}
				}
			}
		},
		{
			name = "mode",
			description = "Select the matchmaking mode",
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
					name = "mode",
					description = "A matchmaking mode",
					type = commandOptionType.string,
					required = true,
					choices = {
						{
							name = "random",
							value = "random"
						},
						{
							name = "max",
							value = "max"
						},
						{
							name = "min",
							value = "min"
						},
						{
							name = "first",
							value = "first"
						},
						{
							name = "last",
							value = "last"
						}
					}
				}
			}
		}
	}
}