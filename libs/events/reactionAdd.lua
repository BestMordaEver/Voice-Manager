local discordia = require "discordia"
local embeds = require "embeds"
local actions = require "actions/init"

local client = discordia.storage.client
local logger = discordia.storage.logger
local reactions = embeds.reactions

return function (reaction, userID) -- embeds processing
	-- check extensively if it's even our business
	if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
		return
	end
	
	local embedData = embeds[reaction.message]
	
	logger:log(4, "GUILD %s USER %s on EMBED %s => added %s", reaction.message.guild.id, userID, reaction.message.id, reactions[reaction.emojiHash])
	
	-- just find corresponding emoji and pass instructions to embed
	if reaction.emojiHash == reactions.left then
		embeds:updatePage(reaction.message, embedData.page - 1)
	elseif reaction.emojiHash == reactions.right then
		embeds:updatePage(reaction.message, embedData.page + 1)
	elseif reaction.emojiHash == reactions.page then
		reaction.message.channel:broadcastTyping()
		local ids = {}
		for i = embedData.page*10 - 9, embedData.page*10 do
			if not embedData.ids[i] then break end
			table.insert(ids, embedData.ids[i])
		end
		(actions[embedData.action] or actions[embedData.action:match("^template")] or actions[embedData.action:match("^target")])
			(reaction.message, ids, embedData.action:match("^template(.+)$") or embedData.action:match("^target(.+)$"))
	elseif reaction.emojiHash == reactions.all then
		reaction.message.channel:broadcastTyping(); -- without semicolon next parenthesis is interpreted as a function call :\
		(actions[embedData.action] or actions[embedData.action:match("^template")] or actions[embedData.action:match("^target")])
			(reaction.message, embedData.ids, embedData.action:match("^template(.+)$") or embedData.action:match("^target(.+)$"))
	elseif reaction.emojiHash == reactions.stop then
		embeds[reaction.message] = nil
		reaction.message:delete()
	else -- assume a number emoji
		(actions[embedData.action] or actions[embedData.action:match("^template")] or actions[embedData.action:match("^target")])
			(reaction.message, {embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]]}, 
				embedData.action:match("^template(.+)$") or embedData.action:match("^target(.+)$"))
	end
end