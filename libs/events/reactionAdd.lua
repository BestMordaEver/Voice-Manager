local discordia = require "discordia"
local embeds = require "embeds/embeds"
local logAction = require "utils/logAction"

local client = discordia.storage.client
local logger = discordia.storage.logger
local reactions = embeds.reactions

return function (reaction, userID) -- embeds processing
	-- check extensively if it's even our business
	if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
		return
	end
	
	local embedData = embeds[reaction.message]
	
	if reaction.message.guild then
		logger:log(4, "GUILD %s USER %s on EMBED %s => added %s", reaction.message.guild.id, userID, reaction.message.id, reactions[reaction.emojiHash])
	else
		logger:log(4, "In DM USER %s on EMBED %s => added %s", userID, reaction.message.id, reactions[reaction.emojiHash])
	end
	
	-- call the command, log it, and all in protected call
	reaction:delete(userID)
	local res = embedData(reaction)
	embedData.killIn = 10
	
	-- notify user if failed
	if res then
		logAction(reaction.message, res)
	end
	
	logger:log(4, "EMBED %s - processed", reaction.message.id)
end