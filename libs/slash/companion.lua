local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

---@module "locale/slash/en-US"
local locale = require "locale/localeHandler"

return {
		name = locale.companion,
		description = locale.companionDesc,
		contexts = {contextType.guild},
		options = {
			{
				name = locale.view,
				description = locale.companionViewDesc,
				type = commandOptionType.subcommand,
				options = {
					{
						name = locale.lobby,
						description = locale.lobbyViewLobbyDesc,
						type = commandOptionType.channel,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = locale.enable,
				description = locale.companionEnableDesc,
				type = commandOptionType.subcommand,
				options = {
					{
						name = locale.lobby,
						description = locale.companionEnableLobbyDesc,
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = locale.disable,
				description = locale.companionDisableDesc,
				type = commandOptionType.subcommand,
				options = {
					{
						name = locale.lobby,
						description = locale.companionEnableLobbyDesc,
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = locale.category,
				description = locale.companionCategoryDesc,
				type = commandOptionType.subcommand,
				options = {
					{
						name = locale.lobby,
						description = locale.lobbyConfigured,
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = locale.category,
						description = locale.companionCategoryCategoryDesc,
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.category
						}
					}
				}
			},
			{
				name = locale.name,
				description = locale.companionNameDesc,
				type = commandOptionType.subcommand,
				options = {
					{
						name = locale.lobby,
						description = locale.lobbyConfigured,
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = locale.name,
						description = locale.companionNameNameDesc,
						type = commandOptionType.string,
						required = true
					}
				}
			},
			{
				name = locale.companionGreeting,
				description = locale.companionGreetingDesc,
				type = commandOptionType.subcommand,
				options = {
					{
						name = locale.lobby,
						description = locale.lobbyConfigured,
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = locale.companionGreeting,
						description = locale.companionGreetingGreetingDesc,
						type = commandOptionType.string
					}
				}
			},
			{
				name = locale.companionLog,
				description = locale.companionLogDesc,
				type = commandOptionType.subcommand,
				options = {
					{
						name = locale.lobby,
						description = locale.lobbyConfigured,
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = locale.channel,
						description = locale.companionLogChannelDesc,
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