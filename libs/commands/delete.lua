local client = require "client"

local okResponse = require "response/ok"
local warningResponse = require "response/warning"
local deleteResponse = require "response/delete"
local response = require "response/response"

local checkSetupPermissions = require "channelUtils/checkSetupPermissions"
local truePositionSort = require "utils/truePositionSort"

local interactionType = require "discordia".enums.interactionType

return function (interaction, action)
	if interaction.type == interactionType.applicationCommand then	-- slash command
		local options = interaction.options
		local type = options.type.value
		local category = options.category and options.category.value
		local amount = options.amount and options.amount.value or 100
		local name = options.name and options.name.value
		local only_empty = options.only_empty and options.only_empty.value

		local ok, logMsg, response = checkSetupPermissions(interaction, category)
		if not ok then
			return logMsg, response
		end

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

		if #channels == 0 then return "No channels to delete", warningResponse(true, interaction.locale, "deleteNone") end
		table.move({}, 1, #channels - amount, amount + 1, channels)

		return "Deletion list is formed", deleteResponse(true, interaction.locale, channels)

	else	-- sent from component, absolute anarchy
		-- no perm check, since component is on ephemeral message, that was sent to permed user

		local components = interaction.message.components[1].components
		local argument = tonumber(interaction.customId:match("[^_]+$"))

		if action == "key" then    -- delete provides four keys that need to be armed
			components[#components].components[argument].style = 3
			return "Key is armed", response:generic(true, components)

		elseif action == "nuke" then   -- nuke will go off only when all keys are armed
			local buttons, ready = components[#components].components, true
			for i=1,4 do if buttons[i].style ~= 3 then ready = false end end

			if not ready then
				interaction:reply(warningResponse(true, interaction.locale, "deleteNotArmed"))
				return "Not all keys are armed"
			end

			interaction:update(deleteResponse(true, interaction.locale))

			local count = 0
			for i=2,#components-1 do
				for _, option in ipairs(components[i].components[1].options) do
					if option.default then
						local channel = client:getChannel(option.value)
						if channel and channel:delete() then count = count + 1 end
					end
				end
			end

			return "Deleted the channels", okResponse(true, interaction.locale, "deleteConfirm", count)

		elseif action == "row" then    -- user edited delete list
			local row = {}
			for _, value in ipairs(interaction.values) do
				row[value] = true
			end

			for _, option in ipairs(components[argument].components[1].options) do
				option.default = row[option.value]
			end

			return "Changes saved", response:generic(true, components)
		end
	end
end