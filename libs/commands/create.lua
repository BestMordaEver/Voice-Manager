local locale = require "locale"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"

local permissionCheck = require "funcs/permissionCheck"

local channelType = require "discordia".enums.channelType

return function (interaction)
	local type, amount, name = interaction.options.type.value, interaction.options.amount.value, interaction.options.name.value
	local category = interaction.options.category and interaction.options.category.value

	local isPermitted, logMsg, userMsg = permissionCheck(interaction, category)
	if not isPermitted then
		return logMsg, warningEmbed(userMsg)
	end

	if category and #category.textChannels + #category.voiceChannels + amount > 50 then
		return "Create aborted, category overflow", warningEmbed(locale.createCategoryOverflow)
	end

	local success = 0
	for i=1,amount do
		if interaction.guild:createChannel({
			name = name:gsub("%%counter%%", tostring(i)),
			type = channelType[type],
			parent_id = category and category.id
		}) then
			success = success + 1
		end
	end

	return "Created channels", okEmbed(locale.createConfirm:format(success))
end