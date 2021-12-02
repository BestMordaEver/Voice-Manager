local client = require "client"
local locale = require "locale"
local embeds = require "embeds/embeds"
local guilds = require "storage/guilds"

local reactions = embeds.reactions
local colors = embeds.colors
local gs, insert = string.gsub, table.insert

local helpEmbed = {}

local tostring = function (self)
	return "HelpEmbed: "..self.id
end

function helpEmbed:setContent(page)
	local prefix = guilds[(self.guild or self.message.guild).id].prefix
	if prefix:match("%w$") then prefix = prefix .. " " end

	self.embed = {
		title = locale.helpTitle[page],
		color = colors.blurple,
		description = gs(locale.helpDescription[page], "%%prefix%%", prefix)
	}
	self.embed.fields = {}

	for i, name in ipairs(locale.helpFieldNames[page]) do
		insert(self.embed.fields, {
			name = gs(name, "%%prefix%%", prefix),
			value = gs(locale.helpFieldValues[page][i], "%%prefix%%", prefix)
		})
	end

	insert(self.embed.fields, {name = locale.helpLinksTitle, value = locale.helpLinks})
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
	if type ~= "help" or not newMessage then return end
	local embedData = setmetatable({command = "help", killIn = 10, author = message.author, embed = embed, guild = message.guild}, metaHelp)

	embeds[newMessage] = embedData
	embedData.id = newMessage.id

	newMessage:addReaction(reactions.page)
	for i=1,7 do
		newMessage:addReaction(reactions[i])
	end
	newMessage:addReaction(reactions.stop)
end)

embeds:new("help", function (page, message)
	local embed = {message = message}
	helpEmbed.setContent(embed, page)
	return embed.embed
end)