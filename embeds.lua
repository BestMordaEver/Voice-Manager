local discordia = require "discordia"
local client, sqlite, logger = discordia.storage.client, discordia.storage.sqlite, discordia.storage.logger
local locale = require "./locale.lua"
local guilds = require "./guilds.lua"

return setmetatable({}, {
	__index = {
		reactions = {"1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟",
			["1️⃣"] = 1, ["2️⃣"] = 2, ["3️⃣"] = 3, ["4️⃣"] = 4, ["5️⃣"] = 5, ["6️⃣"] = 6, ["7️⃣"] = 7, ["8️⃣"] = 8, ["9️⃣"] = 9, ["🔟"] = 10,
			left = "⬅", right = "➡"},
		
		new = function (self, locale, action, page, ids)
			local reactions = self.reactions
			local embed = {title = action == "register" and locale.embedRegister or locale.embedUnregister, description = ""}
			
			for i=10*(page-1)+1,10*page do
				if not ids[i] then break end
				local channel = client:getChannel(ids[i])
				embed.description = embed.description.."\n"..reactions[math.fmod(i-1,10)+1]..
					string.format(channel.category and locale.channelNameCategory or "`%s`", channel.name, channel.category and channel.category.name)
			end
			
			return embed
		end,
		
		decorate = function (self, message)
			local reactions = self.reactions
			local embedData = self[message]
			if embedData.page ~= 1 then message:addReaction(reactions.left) end
			for i=10*(embedData.page-1)+1, 10*embedData.page do
				if not embedData.ids[i] then break end
				message:addReaction(reactions[math.fmod(i-1,10)+1])
			end
			if embedData.page ~= math.modf(#embedData.ids/10)+1 then message:addReaction(reactions.right) end
		end,
		
		send = function (self, message, action, ids)
			local embed = self:new(guilds[message.guild.id].locale, action, 1, ids)
			local newMessage = message:reply {embed = embed}
			self[newMessage] = {embed = embed, killIn = 10, ids = ids, page = 1, action = action, author = message.author}
			self:decorate(newMessage)
			
			logger:log(4, "Created embed "..newMessage.id)
			return newMessage
		end,
		
		updatePage = function (self, message, page)
			local embedData = self[message]
			embedData.embed = self:new(getLocale(message.guild), embedData.action, page, embedData.ids)
			embedData.killIn = 10
			embedData.page = page
			
			message:clearReactions()
			message:setEmbed(embedData.embed)
			self:decorate(message)
		end,
		
		tick = function (self)
			for message, embedData in pairs(self) do
				if client:getChannel(message.channel):getMessage(message) then
					embedData.killIn = embedData.killIn - 1
					if embedData.killIn == 0 then
						self[message] = nil 
					end
				else
					self[message] = nil
				end
			end
		end
	}
})
