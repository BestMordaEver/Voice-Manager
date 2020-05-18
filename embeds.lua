local discordia = require "discordia"
local client, sqlite, logger = discordia.storage.client, discordia.storage.sqlite, discordia.storage.logger
local guilds = require "./guilds.lua"
local locale = require "./locale"

return setmetatable({}, {
	__index = {
		reactions = {"1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟",
			["1️⃣"] = 1, ["2️⃣"] = 2, ["3️⃣"] = 3, ["4️⃣"] = 4, ["5️⃣"] = 5, ["6️⃣"] = 6, ["7️⃣"] = 7, ["8️⃣"] = 8, ["9️⃣"] = 9, ["🔟"] = 10,
			left = "⬅", right = "➡", page = "📄", all = "*️⃣"},
		
		new = function (self, action, page, ids)
			local reactions = self.reactions
			local template = action:match("^template(.-)$")
			local nids = #ids
			
			local embed = {
				title =
					action == "register" and (nids > 10 and locale.embedRegisterPages or locale.embedRegister) or (
					action == "unregister" and (nids > 10 and locale.embedUnregisterPages or locale.embedUnregister) or (
					template == "" and (nids > 10 and locale.embedResetTemplatePages or locale.embedResetTemplate) or 
						(nids > 10 and locale.embedTemplatePages or locale.embedTemplate):format(template))),
				description = "",
				footer = nids > 10 and {text = locale.embedPages:format(page, math.ceil(nids/10))} or nil
			}
			
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
			if #embedData.ids > 10 then message:addReaction(reactions.page) end
			message:addReaction(reactions.all)
		end,
		
		send = function (self, message, action, ids)
			local embed = self:new(action, 1, ids)
			local newMessage = message:reply {embed = embed}
			if newMessage then
				self[newMessage] = {embed = embed, killIn = 10, ids = ids, page = 1, action = action, author = message.author}
				self:decorate(newMessage)
				
				return newMessage
			end
		end,
		
		updatePage = function (self, message, page)
			local embedData = self[message]
			embedData.embed = self:new(embedData.action, page, embedData.ids)
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
