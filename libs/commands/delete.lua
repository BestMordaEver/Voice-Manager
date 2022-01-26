local client = require "client"
local locale = require "locale"

local warningEmbed = require "embeds/warning"
local dialogue = require "utils/dialogue"
local templateInterpreter = require "funcs/templateInterpreter"

local channelType = require "discordia".enums.channelType

return function (message, argument)
	return "unfinished", warningEmbed(locale.unfinishedCommand)
	--[[local category = client:getChannel(dialogue[message.author.id])
	if not category or category.type ~= channelType.category then
		return "No category selected", "warning", locale.noCategorySelected
	end

	local type, direction, amount, name = argument:match("(%a+)%s*(%a-)%s*(%d+)%s*(.-)$")

	if type ~= "voice" and type ~= "text" then
		return "Unknown type", "warning", locale.badType:format(type)
	end

	if direction ~= "bottom" then direction = "top" end

	amount = tonumber(amount)
	if not amount or amount < 1 or amount > 50 then
		return "Channel amount not a number", "warning", locale.amountNotANumber
	elseif #category.voiceChannels + #category.textChannels + amount > 50 then
		return "Channel amount OOB", "warning", locale.amountOOB
	end

	if templateInterpreter(name, message.member, 1) == "" then
		return "Empty name", "warning", locale.emptyName
	end]]
end