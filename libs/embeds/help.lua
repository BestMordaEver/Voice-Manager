local locale = require "locale"
local embedHandler = require "handlers/embedHandler"
local buttons = require "handlers/componentHandler".helpButtons

local blurple = embedHandler.colors.blurple
local insert = table.insert

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