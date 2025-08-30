local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"

return function (interaction)
	local options = interaction.options
	local source, amount = options.source.value, options.amount.value
	local category, name = source.category, options.name and options.name.value or source.name

	local ok, logMsg, embed = checkSetupPermissions(interaction, category)
	if not ok then
		return logMsg, embed -- TODO: server-wide ignore warnings?
	end

	if category and #category.textChannels + #category.voiceChannels + amount > 50 then
		return "Create aborted, category overflow", warningEmbed(interaction, "createCategoryOverflow")
	end

	local success, start = 0, tonumber(name:match("%%counter%((%d+)%)%%")) or 1
	for i=1, amount do
		if source.guild:createChannel({
			name = name and name:gsub("%%counter.-%%", tostring(i + start - 1)) or source.name,
			type = source.type,
			parent_id = category and category.id
		}) then
			success = success + 1
		end
	end

	return "Created channels", okEmbed(interaction, "createConfirm", success)
end