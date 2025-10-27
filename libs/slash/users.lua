local enums = require "discordia".enums
local channelType = enums.channelType
local commandOptionType = enums.applicationCommandOptionType
local contextType = enums.interactionContextType

---@module "locale/slash/en-US"
local locale = require "locale/slash/localeHandler"

return {
	name = locale.users,
	description = locale.usersDesc,
	contexts = {contextType.guild},
	options = {
		{
			name = locale.usersPrint,
			description = locale.usersPrintDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.channel,
					description = locale.usersPrintChannelDesc,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice,
						channelType.stageVoice,
						channelType.category
					}
				},
				{
					name = locale.usersPrintPrint_as,
					description = locale.usersPrintPrint_asDesc,
					type = commandOptionType.string,
					choices = {
						{
							name = locale.usersPrintPrint_asUsername,
							value = "username"
						},
						{
							name = locale.usersPrintPrint_asTag,
							value = "tag"
						},
						{
							name = locale.usersPrintPrint_asNickname,
							value = "nickname"
						},
						{
							name = locale.usersPrintPrint_asMention,
							value = "mention"
						},
						{
							name = locale.usersPrintPrint_asId,
							value = "id"
						}
					}
				},
				{
					name = locale.usersPrintSeparator,
					description = locale.usersPrintSeparatorDesc,
					type = commandOptionType.string
				}
			}
		},
		{
			name = locale.usersGive,
			description = locale.usersGiveDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.channel,
					description = locale.usersGiveChannelDesc,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice,
						channelType.stageVoice,
						channelType.category
					}
				},
				{
					name = locale.role,
					description = locale.usersGiveRoleDesc,
					type = commandOptionType.role,
					required = true
				}
			}
		},
		{
			name = locale.remove,
			description = locale.usersGiveDesc,
			type = commandOptionType.subcommand,
			options = {
				{
					name = locale.channel,
					description = locale.usersGiveChannelDesc,
					type = commandOptionType.channel,
					required = true,
					channel_types = {
						channelType.voice,
						channelType.stageVoice,
						channelType.category
					}
				},
				{
					name = locale.role,
					description = locale.usersGiveRoleDesc,
					type = commandOptionType.role,
					required = true
				}
			}
		}
	}
}