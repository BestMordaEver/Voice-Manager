local client = require "client"
local logger = require "logger"
local embeds = require "embeds/embeds"

local reactions = embeds.reactions

return function (reaction, userID) -- embeds processing
	-- check extensively if it's even our business
	if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
		return
	end
	
	local embedData = embeds[reaction.message]
	
	logger:log(4, "GUILD %s USER %s EMBED %s => added %s", reaction.message.guild.id, userID, reaction.message.id, reactions[reaction.emojiHash])
	
	reaction:delete(userID)
	embedData(reaction)
	embedData.killIn = 10
	
	logger:log(4, "GUILD %s USER %s EMBED %s: processed", reaction.message.guild.id, userID, reaction.message.id)
end