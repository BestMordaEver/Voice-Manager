local client = require "discordia".storage.client
local config = require "config"

local locale = require "locale"
local commandFinalize = require "commands/commandFinalize"
local bitfield = require "utils/bitfield"
local isComplex = require "utils/isComplex"

local embeds = require "libs/embeds/embeds"
local reactions = embeds.reactions

local isProbing = function (action, argument)
	return isComplex(action) and argument ~= "" or not isComplex(action)
end

local commandEmbed = {}

local tostring = function (self)
	return "CommandEmbed: "..self.id
end

function commandEmbed:setContent(ids, page)
	local nids, action, argument = #ids, self.action, self.argument
	if action == "permissions" and argument and argument ~= "" then argument = bitfield(argument) end
	if argument and client:getChannel(argument) then argument = client:getChannel(argument).name end
	
	-- this is the most compact way to relatively quickly perform all required checks
	-- good luck
	self.embed = {
		title = action:gsub("^.", string.upper, 1),	-- upper bold text
		color = config.embedColor,
		description = (
			action == "register" and locale.embedRegister or 
			action == "unregister" and locale.embedUnregister or 
			action == "template" and (argument and (argument == "" and locale.embedLobbyTemplate or locale.embedTemplate) or locale.embedResetTemplate) or
			action == "target" and (argument and (argument == "" and locale.embedLobbyTarget or locale.embedTarget) or locale.embedResetTarget) or
			action == "permissions" and (argument and (argument == "" and locale.embedLobbyPermissions or 
				(argument:has(bitfield.bits.on) and locale.embedAddPermissions or locale.embedRemovePermissions)) or locale.embedResetPermissions) or
			action == "capacity" and (argument and (argument == "" and locale.embedLobbyCapacity or locale.embedCapacity) or locale.embedResetCapacity) or
			action == "companion" and (argument and (argument == "" and locale.embedLobbyCompanion or locale.embedCompanion) or locale.embedResetCompanion)
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
end

function commandEmbed:decorate(message)
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
end

commandEmbed[reactions.left] = function (self, reaction)
	self:setContent(self.ids, self.page - 1, self.action, self.argument)
	self.page = self.page - 1
	
	reaction.message:clearReactions()
	reaction.message:setEmbed(self.embed)
	self:decorate(reaction.message)
end

commandEmbed[reactions.right] = function (self, reaction)
	self:setContent(self.ids, self.page + 1, self.action, self.argument)
	self.page = self.page + 1
	
	reaction.message:clearReactions()
	reaction.message:setEmbed(self.embed)
	self:decorate(reaction.message)
end

commandEmbed[reactions.page] = function (self, reaction)
	reaction.message.channel:broadcastTyping()
	local ids = {}
	for i = self.page*10 - 9, self.page*10 do
		if not self.ids[i] then break end
		table.insert(ids, self.ids[i])
	end
	return commandFinalize[self.action](reaction.message, ids, self.argument)
end

commandEmbed[reactions.all] = function (self, reaction)
	reaction.message.channel:broadcastTyping()
	return commandFinalize[self.action](reaction.message, self.ids, self.argument)
end

commandEmbed[reactions.stop] = function (self, reaction)
	embeds[reaction.message] = nil
	reaction.message:delete()
end

function commandEmbed:numbers(reaction)
	return commandFinalize[self.action](reaction.message, {self.ids[(self.page-1) * 10 + reactions[reaction.emojiHash]]}, self.argument)
end

local onPress = function (self, reaction)
	if self[reaction.emojiHash] then
		self[reaction.emojiHash](self, reaction)
	else
		self:numbers(reaction)
	end
end

local metaCommand = {
	__call = onPress,
	__tostring = tostring,
	__index = commandEmbed
}
			
return function (message, ids, action, argument)
	local embedData = setmetatable({killIn = 10, ids = ids, page = 1, action = action, argument = argument, author = message.author}, metaCommand)
	embedData:setContent(ids, 1)
	local newMessage = message:reply {embed = embedData.embed}
	if newMessage then
		embeds[newMessage] = embedData
		embedData.id = newMessage.id
		embedData:decorate(newMessage)
		
		return newMessage
	end
end