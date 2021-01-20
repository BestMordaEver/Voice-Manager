local client = require "client"
local config = require "config"
local locale = require "locale"
local embeds = require "embeds/embeds"
local reactions = embeds.reactions

local helpEmbed = {}

local tostring = function (self)
	return "HelpEmbed: "..self.id
end

function helpEmbed:setContent(page)
	self.embed = {
		title = locale.helpTitle[page],
		color = 6561661,
		description = locale.helpDescription[page]
	}
	self.embed.fields = {}
	
	for i, name in ipairs(locale.helpFieldNames[page]) do
		table.insert(self.embed.fields, {name = name, value = locale.helpFieldValues[page][i]})
	end
	
	table.insert(self.embed.fields, {name = locale.helpLinksTitle, value = locale.helpLinks})
end

helpEmbed[reactions.stop] = function (self, reaction)
	embeds[reaction.message] = nil
	reaction.message:delete()
end

helpEmbed[reactions.page] = function (self, reaction)
	self:setContent(0)
	reaction.message:setEmbed(self.embed)
end

function helpEmbed:numbers(reaction)
	self:setContent(reactions[reaction.emojiHash])
	reaction.message:setEmbed(self.embed)
end

local metaHelp = {
	__call = function (self, reaction)
		if self[reaction.emojiHash] then
			self[reaction.emojiHash](self, reaction)
		else
			self:numbers(reaction)
		end
	end,
	__tostring = tostring,
	__index = helpEmbed
}

-- event is sent when embed is formed and delivered
-- only relevant for interactive embeds
client:on("embedSent", function (type, message, newMessage, embed)
	if type ~= "help" then return end
	local embedData = setmetatable({command = "help", killIn = 10, author = message.author, embed = embed}, metaHelp)
	
	embeds[newMessage] = embedData
	embedData.id = newMessage.id
	
	newMessage:addReaction(reactions.page)
	for i=1,7 do
		newMessage:addReaction(reactions[i])
	end
	newMessage:addReaction(reactions.stop)
end)

embeds:new("help", function (page)
	local embed = {}
	helpEmbed.setContent(embed, page)
	return embed.embed
end)