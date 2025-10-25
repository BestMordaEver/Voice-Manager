local enums = require "discordia".enums
local componentType = enums.componentType
local buttonStyle = enums.buttonStyle

local response = require "response/response"
local localeHandler = require "locale/runtime/localeHandler"

local insert, modf, fmod = table.insert, math.modf, math.fmod

local buttons = {
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
}

---@overload fun(ephemeral : boolean, locale : localeName, channel? : GuildVoiceChannel) : table
local deleteWidget = response("deleteWidget", response.colors.blurple, function (locale, channels)
	if not channels then return {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "deleteProcessing")
		}
	} end

	local components = {
		{
			type = componentType.textDisplay,
			content = localeHandler(locale, "deleteForm", #channels)
		}
	}

	for i=1,#channels do
		local row = modf((i-1)/25) + 2

		if fmod(i-1, 25) == 0 then
			insert(components, {type = 1, components = {{type = 3, custom_id = "delete_row_"..row, min_values = 0, options = {}}}})
		end

		local channel = channels[i]

		insert(components[row].components[1].options, {
			label = channel.name,
			value = channel.id,
			description = channel.category and localeHandler(locale, "inCategory", channel.category.name),
			default = true
		})
	end

	for _, row in pairs(components) do
		if row.components then
			row.components[1].max_values = #row.components[1].options
		end
	end

	insert(components, buttons)

	return components
end)

return deleteWidget