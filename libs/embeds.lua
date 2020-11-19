--[[
object to store data about embeds. there's no database to store data about embeds as there's no need for that
embeds are enhanced message structures with additional formatting options
https://leovoel.github.io/embed-visualizer/
https://discord.com/developers/docs/resources/channel#embed-object
]]

local discordia = require "discordia"
local client, sqlite, logger = discordia.storage.client, discordia.storage.sqlite, discordia.storage.logger

local locale = require "locale"
local prefinalizer = require "prefinalizer"
local bitfield = require "utils/bitfield"
local isComplex = require "utils/isComplex"

local isProbing = function (action, argument)
	return isComplex(action) and argument ~= "" or not isComplex(action)
end

-- all relevant emojis
local reactions = {
	"1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟",
	["1️⃣"] = 1, ["2️⃣"] = 2, ["3️⃣"] = 3, ["4️⃣"] = 4, ["5️⃣"] = 5, ["6️⃣"] = 6, ["7️⃣"] = 7, ["8️⃣"] = 8, ["9️⃣"] = 9, ["🔟"] = 10,
	left = "⬅", right = "➡", page = "📄", all = "*️⃣", stop = "❌",
	["⬅"] = "left", ["➡"] = "right", ["📄"] = "page", ["*️⃣"] = "all", ["❌"] = "stop"
}

-- default embedType call processing function
local call = function (self, reaction)
	if self[reaction.emojiHash] then
		self[reaction.emojiHash](self, reaction)
	else
		self:numbers(reaction)
	end
end

local embeds = {}
local embedTypes = {
--[[
	embedType = setmetatable({
		__tostring - give it a name!
		__call = call, -- different function may be used if you want to process calls differently,
		__index = {
			emojiHash = function (self, ...) ... end, ... -- service functions like setContent can be used here
		}
	},{
		__call = function (self, ...) -- embed factory function
	})
	
	all types must include following fields:
	action - name of performed action, for logging purposes
	killIn - amount of minutes that embed serves, will be automatically set to 10 after every interaction
	author = message.author - for ownership checks
]]
--[[
	killIn = 10
	author = message.author
	id = newMessage.id
	page = 1
	action = "help"
]]
	help = setmetatable({
		__call = call,
		__tostring = function (self)
			return "HelpEmbed: "..self.id
		end,
		__index = {
			setContent = function (self, page)
				self.embed = {
					title = page == 1 and locale.helpLobbyTitle or
						page == 2 and locale.helpMatchmakingTitle or
						page == 3 and locale.helpHostTitle or
						page == 4 and locale.helpServerTitle or
						locale.helpOtherTitle,
					color = 6561661,
					description = (page == 1 and locale.helpLobby or
						page == 2 and locale.helpMatchmaking or
						page == 3 and locale.helpHost or
						page == 4 and locale.helpServer or
						locale.helpOther)..locale.links,
					footer = {text = locale.embedPages:format(page,5).." | "..locale.embedDelete}
				}
			end,
			
			[reactions.stop] = function (self, reaction)
				embeds[reaction.message] = nil
				reaction.message:delete()
			end,
			
			numbers = function (self, reaction)
				self:setContent(reactions[reaction.emojiHash])
				self.page = page
				reaction.message:setEmbed(self.embed)
			end
		}
	},{
		__call = function (self, message)
			local embedData = setmetatable({action = "help", killIn = 10, page = 1, author = message.author}, self)
			embedData:setContent(1)
			
			local newMessage = message:reply {embed = embedData.embed}
			if newMessage then
				embeds[newMessage] = embedData
				embedData.id = newMessage.id
				
				for i=1,5 do
					newMessage:addReaction(reactions[i])
				end
				newMessage:addReaction(reactions.stop)
				
				return newMessage
			end
		end
	}),
	
--[[
	killIn = 10
	author = message.author
	id = newMessage.id
	page
	ids = {array of channelIDs}
	action - name of the action embed performs
	argument - if action is complex, this might have useful information
]]
	actions = setmetatable({
		__call = call,
		__tostring = function (self)
			return "ActionEmbed: "..self.id
		end,
		__index = {
			setContent = function (self, ids, page)
				local nids, action, argument = #ids, self.action, self.argument
				if action == "permissions" and argument ~= "" then argument = bitfield(argument) end
				
				-- this is the most compact way to relatively quickly perform all required checks
				-- good luck
				self.embed = {
					title = action:gsub("^.", string.upper, 1),	-- upper bold text
					color = 6561661,
					description = (
						action == "register" and locale.embedRegister or 
						action == "unregister" and locale.embedUnregister or 
						action == "template" and (argument == "" and locale.embedLobbyTemplate or locale.embedTemplate) or
						action == "target" and (argument == "" and locale.embedLobbyTarget or locale.embedTarget) or
						action == "permissions" and (argument == "" and locale.embedLobbyPermissions or 
							(bitfield(argument):has(bitfield.bits.on) and locale.embedAddPermissions or locale.embedRemovePermissions)) or
						action == "capacity" and (argument == "" and locale.embedLobbyCapacity or locale.embedCapacity)
					):format(argument).."\n"..(
					-- probing actions don't need asterisk and page, we can't learn several templates/targets...
						isProbing(action, argument) and (
							((nids > 10) and (locale.embedPage.."\n") or "")..(locale.embedAll.."\n")) or ""),
					footer = {text = (nids > 10 and (locale.embedPages:format(page, math.ceil(nids/10)).." | ") or "")..locale.embedDelete}	-- page number
				}
				
				for i=10*(page-1)+1,10*page do
					if not ids[i] then break end
					local channel = client:getChannel(ids[i])
					self.embed.description = self.embed.description.."\n"..reactions[math.fmod(i-1,10)+1]..
						string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category")
				end
			end,
			
			-- sprinkle those button emojis!
			decorate = function (self, message)
				if self.page ~= 1 then message:addReaction(reactions.left) end
				for i=10*(self.page-1)+1, 10*self.page do
					if not self.ids[i] then break end
					message:addReaction(reactions[math.fmod(i-1,10)+1])
				end
				if self.page ~= math.modf(#self.ids/10)+1 then message:addReaction(reactions.right) end
				
				if isProbing(self.action, self.argument) then
					if #self.ids > 10 then message:addReaction(reactions.page) end
					if #self.ids > 0 then message:addReaction(reactions.all) end
				end
				
				message:addReaction(reactions.stop)
			end,
			
			[reactions.left] = function (self, reaction)
				self:setContent(self.ids, self.page - 1, self.action, self.argument)
				self.page = page
				
				reaction.message:clearReactions()
				reaction.message:setEmbed(self.embed)
				self:decorate(reaction.message)
			end,
			
			[reactions.right] = function (self, reaction)
				self:setContent(self.ids, self.page + 1, self.action, self.argument)
				self.page = page
				
				reaction.message:clearReactions()
				reaction.message:setEmbed(self.embed)
				self:decorate(reaction.message)
			end,
			
			[reactions.page] = function (self, reaction)
				reaction.message.channel:broadcastTyping()
				local ids = {}
				for i = self.page*10 - 9, self.page*10 do
					if not self.ids[i] then break end
					table.insert(ids, self.ids[i])
				end
				actions[self.action](reaction.message, ids, self.argument)
			end,
			
			[reactions.all] = function (self, reaction)
				reaction.message.channel:broadcastTyping()
				actions[self.action](reaction.message, self.ids, self.argument)
			end,
			
			[reactions.stop] = function (self, reaction)
				embeds[reaction.message] = nil
				reaction.message:delete()
			end,
			
			numbers = function (self, reaction)
				return prefinalizer[self.action](reaction.message, {self.ids[(self.page-1) * 10 + reactions[reaction.emojiHash]]}, self.argument)
			end
		}
	},{
		__call = function (self, message, ids, action, argument)
			local embedData = setmetatable({killIn = 10, ids = ids, page = 1, action = action, argument = argument, author = message.author}, self)
			embedData:setContent(ids, 1)
			local newMessage = message:reply {embed = embedData.embed}
			if newMessage then
				embeds[newMessage] = embedData
				embedData.id = newMessage.id
				embedData:decorate(newMessage)
				
				return newMessage
			end
		end
	})
}


return setmetatable(embeds, {
	-- move functions and static data to index table to iterate over embeds easily
	__index = {
		reactions = reactions,
		
		embedTypes = embedTypes,
		
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
		end
	}
})
