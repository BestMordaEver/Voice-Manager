local client = require "client"

local insert = table.insert

local componentType = require "discordia".enums.componentType
local localeHandler = require "locale/localeHandler"
local response = require "response/response"

---@overload fun(ephemeral : boolean, interaction : SlashInteraction) : table
local region = response("region", response.colors.blurple, function (interaction)
	local options = {}
	local components = {
		{
			type = componentType.textDisplay,
			content = localeHandler(interaction.locale, "regionSelect")
		},
		{
			type = componentType.row,
			components = {{
				type = componentType.stringSelect,
				custom_id = "lobby_region_"..interaction.option.value.id,
				options = options
			}}
		}
	}

	for _, region in pairs(interaction.guild:listVoiceRegions()) do
		insert(options, {
			label = region.name,
			value = region.id,
			description = ("%s %s %s"):format(region.optimal and "optimal" or "", region.deprecated and "deprecated" or "", region.custom and "custom" or "")
		})
	end

	return components
end)

return region