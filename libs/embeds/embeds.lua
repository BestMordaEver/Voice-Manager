--[[
all relevant data about embeds can be accessed here, different embed types are defined in separate files
embeds are enhanced message structures with additional formatting options
https://leovoel.github.io/embed-visualizer/
https://discord.com/developers/docs/resources/channel#embed-object
]]

return setmetatable({}, {
	__index = {
		types = {},
		-- all relevant emojis
		reactions = {
			"1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟",
			["1️⃣"] = 1, ["2️⃣"] = 2, ["3️⃣"] = 3, ["4️⃣"] = 4, ["5️⃣"] = 5, ["6️⃣"] = 6, ["7️⃣"] = 7, ["8️⃣"] = 8, ["9️⃣"] = 9, ["🔟"] = 10,
			left = "⬅", right = "➡", page = "📄", all = "*️⃣", stop = "❌",
			["⬅"] = "left", ["➡"] = "right", ["📄"] = "page", ["*️⃣"] = "all", ["❌"] = "stop"
		},
		
		-- it dies if not noticed for long enough
		tick = function (self)
			for message, embedData in pairs(self) do
				if message and message.channel then
					embedData.killIn = embedData.killIn - 1
					if embedData.killIn == 0 then
						self[message] = nil
					end
				else
					self[message] = nil
				end
			end
		end,
		
		new = function (self, name, embedFactory)
			if self.types[name] then
				error("Embed type "..name.." already exists")
			else
				self.types[name] = embedFactory
			end
		end
	},
	
	__call = function (self, type, ...)
		if self.types[type] then
			return {embed = self.types[type](...)}
		else
			error("Invalid embed type: "..tostring(type))
		end
	end
})
