local client = require "client"
local locale = require "locale/runtime/localeHandler"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local truePositionSort = require "utils/truePositionSort"
local buttons = require "utils/components".deleteButtons

local interactionType = require "discordia".enums.interactionType

local insert, modf = table.insert, math.modf

--[[
delete components follow two structures
components[<rownumber>].components[1].options[<optionnumber>] - select menus
components[#components].components[<buttonnumber>] -- buttons
]]

return function (interaction, action, argument)
	if interaction.type == interactionType.applicationCommand then	-- slash command
		local options = interaction.options
		local type = options.type.value
		local category = options.category and options.category.value
		local amount = options.amount and options.amount.value or 100
		local name = options.name and options.name.value
		local only_empty = options.only_empty and options.only_empty.value

		local ok, logMsg, embed = checkSetupPermissions(interaction, category)
		if not ok then
			return logMsg, embed
		end

		---@diagnostic disable-next-line: undefined-field
		local channels = table.sorted((category or interaction.guild)[type == "text" and "textChannels" or "voiceChannels"]:toArray(function(channel)
			if name and not channel.name:match(name:demagic()) then
				return false
			end
			if only_empty then
				if type == "text" then
					return not channel:getFirstMessage()
				else
					return #channel.connectedMembers == 0
				end
			end
			return true
		end), truePositionSort)

		if #channels == 0 then return "No channels to delete", warningEmbed(interaction, "deleteNone") end

		local channels = table.move(channels, 1, amount, 1, {})

		local storage, components = {}, {}
		for i=1,#channels do
			local row, part = modf((i+24)/25)
			if part == 0 then
				storage[row] = {}
				insert(components, {type = 1, components = {{type = 3, custom_id = "delete_row_"..row, min_values = 0, options = {}}}})
			end
			local channel = channels[i]

			insert(components[row].components[1].options, {
				label = channel.name,
				value = channel.id,
				description = channel.category and locale(interaction.locale, "inCategory", channel.category.name),
				default = true
			})
			storage[row][channel.id] = true
		end

		for _, row in pairs(components) do
			row.components[1].max_values = #row.components[1].options
		end

		insert(components, buttons)

		return "Deletion list is formed", {content = locale(interaction.locale, "deleteForm", #channels), components = components}

	else	-- sent from component, absolute anarchy
		-- no perm check, since component is on ephemeral message, that was sent to permed user

		local components = interaction.message.components

		if action == "key" then    -- delete provides four keys that need to be armed
			components[#components].components[argument].style = 3
			interaction:update {content = interaction.message.content, components = components}
			return "Key is armed"

		elseif action == "nuke" then   -- nuke will go off only when all keys are armed
			local buttons, ready = components[#components].components, true
			for i=1,4 do if buttons[i].style ~= 3 then ready = false end end

			if ready then
				interaction:update {content = locale(interaction.locale, "deleteProcessing"), components = {}}

				local count = 0
				for i=1,#components-1 do
					for _, option in ipairs(components[i].components[1].options) do
						if option.default then
							local channel = client:getChannel(option.value)
							if channel and channel:delete() then count = count + 1 end
						end
					end
				end

				interaction:followup(okEmbed(interaction, "deleteConfirm", count), true)
				return "Deleted the channels"
			else
				interaction:reply(warningEmbed(interaction, "deleteNotArmed"), true)
				return "Not all keys are armed"
			end

		elseif action == "row" then    -- user edited delete list
			local row = {}
			for _, value in ipairs(interaction.values) do
				row[value] = true
			end

			for _, option in ipairs(components[argument].components[1].options) do
				option.default = row[option.value]
			end

			interaction:update {content = interaction.message.content, components = components}
			return "Changes saved"
		end
	end
end