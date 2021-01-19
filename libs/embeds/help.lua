local client = require "client"
local config = require "config"
local locale = require "locale"
local embeds = require "libs/embeds/embeds"
local reactions = embeds.reactions

local helpEmbed = {}

local tostring = function (self)
	return "HelpEmbed: "..self.id
end

-- event is sent when embed is formed and delivered
-- only relevant for interactive embeds
client:on("embedSent", function (type, message, embed)
	if type ~= "help" then return end
	local embedData = setmetatable({command = "help", killIn = 10, author = message.author, embed = embed}, metaHelp)
	
	embeds[message] = embedData
	embedData.id = message.id
	
	message:addReaction(reactions.page)
	for i=1,5 do
		message:addReaction(reactions[i])
	end
	message:addReaction(reactions.stop)
end)

function helpEmbed:setContent(page)
	self.embed = {
		title =
			page == 0 and locale.helpMenuTitle or
			page == 1 and locale.helpLobbyTitle or
			page == 2 and locale.helpMatchmakingTitle or
			page == 3 and locale.helpHostTitle or
			page == 4 and locale.helpServerTitle or
			locale.helpOtherTitle,
		color = config.embedColor,
		description = (
			page == 0 and locale.helpMenu or
			page == 1 and locale.helpLobby or
			page == 2 and locale.helpMatchmaking or
			page == 3 and locale.helpHost or
			page == 4 and locale.helpServer or
			locale.helpOther)..locale.links
	}
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

local onPress = function (self, reaction)
	if self[reaction.emojiHash] then
		self[reaction.emojiHash](self, reaction)
	else
		self:numbers(reaction)
	end
end

local metaHelp = {
	__call = onPress,
	__tostring = tostring,
	__index = helpEmbed
}

embeds:new("help", function (message)
	return {title = locale.helpMenuTitle, color = config.embedColor, description = locale.helpMenu..locale.links}
end)