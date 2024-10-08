local locale = require "locale/runtime/localeHandler"
local enums = require "discordia".enums
local buttonStyle = enums.buttonStyle
local componentType = enums.componentType
local inputStyle = enums.inputStyle

local meta = {__call = function (self) return self end}

local handler = {
	greetingComponents = function (interaction)
		return {
			{
				type = componentType.row,
				components = {
					{
						type = componentType.textInput,
						custom_id = "greeting",
						style = inputStyle.paragraph,
						label = locale(interaction.locale, "greetingModalTitle")
					}
				}
			}
		}
	end,

	deleteButtons = setmetatable({
		type = componentType.row,
		components = {
			{
				type = componentType.button,
				style = buttonStyle.secondary,
				label = "🔑",
				custom_id = "delete_key_1"
			},{
				type = componentType.button,
				style = buttonStyle.secondary,
				label = "🔑",
				custom_id = "delete_key_2"
			},{
				type = componentType.button,
				style = buttonStyle.secondary,
				label = "🔑",
				custom_id = "delete_key_3"
			},{
				type = componentType.button,
				style = buttonStyle.secondary,
				label = "🔑",
				custom_id = "delete_key_4"
			},{
				type = componentType.button,
				style = buttonStyle.danger,
				label = "☢",
				custom_id = "delete_nuke"
			}
		}
	}, meta),

	passwordModal = function (interaction)
		return {
			{
				type = componentType.row,
				components = {
					{
						type = componentType.textInput,
						custom_id = "password",
						label = locale(interaction.locale, "password"),
						style = inputStyle.short
					}
				}
			}
		}
	end,

	passwordInputButton = function (interaction)
		return {
			{
				type = componentType.row,
				components = {
					{
						type = componentType.button,
						style = buttonStyle.primary,
						label = locale(interaction.locale, "passwordEnter"),
						custom_id = "room_passwordinit",
					}
				}
			}
		}
	end,

	roomButtons = setmetatable({
		{
			type = componentType.row,
			components = {
				{
					type = componentType.button,
					style = buttonStyle.success,
					label = "Show",
					custom_id = "room_widget_show_both",
					emoji = {name = "👁"}
				},{
					type = componentType.button,
					style = buttonStyle.success,
					label = "Unlock",
					custom_id = "room_widget_unlock",
					emoji = {name = "🔓"}
				},{
					type = componentType.button,
					style = buttonStyle.success,
					label = "Unmute voice",
					custom_id = "room_widget_unmute_voice",
					emoji = {name = "🔉"}
				},{
					type = componentType.button,
					style = buttonStyle.success,
					label = "Unmute text",
					custom_id = "room_widget_unmute_text",
					emoji = {name = "🖊"}
				}
			}
		},{
			type = componentType.row,
			components = {
				{
					type = componentType.button,
					style = buttonStyle.secondary,
					label = "Hide",
					custom_id = "room_widget_hide_both",
					emoji = {name = "🥷"}
				},{
					type = componentType.button,
					style = buttonStyle.secondary,
					label = "Lock",
					custom_id = "room_widget_lock",
					emoji = {name = "🔒"}
				},{
					type = componentType.button,
					style = buttonStyle.secondary,
					label = "Mute voice",
					custom_id = "room_widget_mute_voice",
					emoji = {name = "🔇"}
				},{
					type = componentType.button,
					style = buttonStyle.secondary,
					label = "Mute text",
					custom_id = "room_widget_mute_text",
					emoji = {name = "📵"}
				}
			}
		}
	}, meta),

	helpButtons = setmetatable({
		{
			type = componentType.row,
			components = {
				{
					type = componentType.button,
					label = "Lobbies",
					custom_id = "help_lobby",
					style = buttonStyle.primary
				},{
					type = componentType.button,
					label = "Matchmaking",
					custom_id = "help_matchmaking",
					style = buttonStyle.primary
				},{
					type = componentType.button,
					label = "Companion",
					custom_id = "help_companion",
					style = buttonStyle.primary
				}
			}
		},{
			type = componentType.row,
			components = {
				{
					type = componentType.button,
					label = "Room",
					custom_id = "help_room",
					style = buttonStyle.primary
				},{
					type = componentType.button,
					label = "Server",
					custom_id = "help_server",
					style = buttonStyle.primary
				},{
					type = componentType.button,
					label = "Other",
					custom_id = "help_other",
					style = buttonStyle.primary
				}
			}
		}
	}, meta)
}

return handler