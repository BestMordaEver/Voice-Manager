local client = require "client"
local locale = require "locale"

local dialogue = require "utils/dialogue"
local templateInterpreter = require "funcs/templateInterpreter"

local channelType = require "discordia".enums.channelType

return function (message, argument)
	return "unfinished", "warning", locale.unfinishedCommand
	--[[local category = client:getChannel(dialogue[message.author.id])
	if not category or category.type ~= channelType.category then
		return "No category selected", "warning", locale.noCategorySelected
	end

	local type, startI, endI, name = argument:match("(%a+)%s*(%d+)%s*(%d*)%s*(.-)$")

	if type ~= "voice" and type ~= "text" then
		return "Unknown type", "warning", locale.badType:format(type)
	end

	startI, endI = tonumber(startI), tonumber(endI)
	local amount = endI and math.abs(startI-endI) or startI

	if not startI or startI < 1 or startI > 50 then
		return "Start index is not a number", "warning", locale.amountNotANumber
	elseif endI and (endI < 1 or endI > 50) then
		return "End index is OOB", "warning", locale.amountNotANumber
	elseif #category.voiceChannels + #category.textChannels + amount > 50 then
		return "Channel amount OOB", "warning", locale.amountOOB
	end

	if templateInterpreter(name, message.member, 1) == "" then
		return "Empty name", "warning", locale.emptyName
	end]]
end