local config = require "config"
local embeds = require "libs/embeds/embeds"
local reactions = embeds.reactions

local helpEmbed = {}

local tostring = function (self)
	return "HelpEmbed: "..self.id
end

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

return function (message)
	local embedData = setmetatable({action = "help", killIn = 10, author = message.author}, metaHelp)
	embedData:setContent(0)
	
	local newMessage = message:reply {embed = embedData.embed}
	if newMessage then
		embeds[newMessage] = embedData
		embedData.id = newMessage.id
		
		newMessage:addReaction(reactions.page)
		for i=1,5 do
			newMessage:addReaction(reactions[i])
		end
		newMessage:addReaction(reactions.stop)
		
		return newMessage
	end
end