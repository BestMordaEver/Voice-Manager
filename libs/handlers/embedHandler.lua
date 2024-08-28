--[[
all relevant data about embeds can be accessed here, different embed types are defined in separate files
embeds are enhanced message structures with additional formatting options
https://leovoel.github.io/embed-visualizer/
https://discord.com/developers/docs/resources/channel#embed-object
]]

local locale = require "locale/runtime/localeHandler"

local wrapper = {
	__call = function (self, ...)
		return self.factory(...)
	end
}

-- this is so ugly :/
local composeMeta = {
	__call = function (self, msg, ...)
		if msg then
			table.insert(self.description, locale(self.locale, msg, ...))
			return self
		else
			local embed = self.parentEmbed(self.locale, "none")
			embed.embeds[1].description = table.concat(self.description)
			return embed
		end
	end
}

local compose = function (self, localeStorage)
	return setmetatable({
		parentEmbed = self,
		locale = localeStorage.locale,
		description = {}
	}, composeMeta)
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
		}
	},

	__call = function (self, name, embedFactory)
		if not self.types[name] then
			self.types[name] = setmetatable({
				factory = embedFactory,
				compose = compose
			}, wrapper)
		end

		return self.types[name]
	end
})
