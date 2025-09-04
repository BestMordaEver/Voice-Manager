local componentType = require "discordia".enums.componentType

local wrapper = {
	__call = function (self, ephemeral, ...)
		return {
			v2_components = true,
			ephemeral = ephemeral,
			components = {
				{
					type = componentType.container,
					accent_color = self.color,
					components = self.factory(...)
				}
			}
		}
	end
}

local defaultWrapper = function (self, ...)
	return {
		v2_components = true,
		components = self.factory()
	}
end

return setmetatable({}, {
	__index = {
		types = {},
		colors = {
			blurple = 0x5865F2,
			green = 0x57F287,
			red = 0xed4245,
			yellow = 0xfee75c,
			white = 0xffffff,
			fuchsia = 0xeb459e,
			black = 0x23272a
		},
		newCustomType = function (self, name, responseFactory, factoryCaller, customFields)
			assert(not self.types[name], name .. " response type already exists!")

			local response = type(customFields) == "table" and table.copy(customFields) or {}
			response.factory = responseFactory
			self.types[name] = setmetatable(response, {_call = factoryCaller or defaultWrapper})

			return response
		end
	},

	__call = function (self, name, color, responseFactory)
		if color then
			assert(not self.types[name], name .. " response type already exists!")

			self.types[name] = setmetatable({
				factory = responseFactory,
				color = color
			}, wrapper)
		end

		return self.types[name]
	end
})
