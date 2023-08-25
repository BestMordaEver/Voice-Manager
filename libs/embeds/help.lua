local locale = require "locale"
local embedHandler = require "handlers/embedHandler"

local enums = require "discordia".enums

local componentType, buttonStyle = enums.componentType, enums.buttonStyle
local blurple = embedHandler.colors.blurple
local insert = table.insert

local buttons = {
	{
		type = componentType.row,
		components = {
			{
				type = componentType.button,
				label = "Lobbies",
				custom_id = "help_1",
				style = buttonStyle.primary
			},{
				type = componentType.button,
				label = "Matchmaking",
				custom_id = "help_2",
				style = buttonStyle.primary
			},{
				type = componentType.button,
				label = "Companion",
				custom_id = "help_3",
				style = buttonStyle.primary
			}
		}
	},{
		type = componentType.row,
		components = {
			{
				type = componentType.button,
				label = "Room",
				custom_id = "help_4",
				style = buttonStyle.primary
			},{
				type = componentType.button,
				label = "Chat",
				custom_id = "help_5",
				style = buttonStyle.primary
			},{
				type = componentType.button,
				label = "Server",
				custom_id = "help_6",
				style = buttonStyle.primary
			},{
				type = componentType.button,
				label = "Other",
				custom_id = "help_7",
				style = buttonStyle.primary
			}
		}
	}
}

local helps = {}
for i=0,#locale.helpTitle do
	local embed = {
		title = locale.helpTitle[i],
		color = blurple,
		description = locale.helpDescription[i],
		fields = {}
	}

	for j, name in ipairs(locale.helpFieldNames[i]) do
		insert(embed.fields, {
			name = name,
			value = locale.helpFieldValues[i][j]
		})
	end

	insert(embed.fields, {name = locale.helpLinksTitle, value = locale.helpLinks})
	helps[i] = embed
end

return embedHandler("help", function (page, ephemeral)
	return {embeds = {helps[tonumber(page)]}, components = buttons, ephemeral = ephemeral}
end)