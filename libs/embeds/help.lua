local locale = require "locale"
local embedHandler = require "handlers/embedHandler"
local buttons = require "handlers/componentHandler".helpButtons

local blurple = embedHandler.colors.blurple
local insert = table.insert

local helps = {}
for name, text in pairs(locale.help) do
	text.color = blurple
	insert(text.fields, {name = locale.helpLinksTitle, value = locale.helpLinks})
	helps[name] = text
end

return embedHandler("help", function (page, ephemeral)
	return {embeds = {helps[page]}, components = buttons, ephemeral = ephemeral}
end)