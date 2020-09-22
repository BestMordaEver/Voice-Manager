local discordia = require "discordia"
local embeds = require "embeds"
local actions = require "actions/init"

local client = discordia.storage.client
local logger = discordia.storage.logger
local reactions = embeds.reactions

-- register -> unregister; unregister -> register; templateblabla -> template; targetblabla -> target
local function antiAction (action)
	return action == "unregister" and "register" or
		action == "register" and "unregister" or
			action == "template" and "template" or "target"	-- reaction remove on template and target will always be interpreted as reset
end

return function (reaction, userID) -- reactionAdd but opposite
	if not reaction.me or client:getUser(userID).bot or not embeds[reaction.message] or embeds[reaction.message].author.id ~= userID then
		return
	end
	
	local embedData = embeds[reaction.message]
	if embedData.action == "help" then return end
	
	logger:log(4, "GUILD %s USER %s on EMBED %s => removed %s", reaction.message.guild.id, userID, reaction.message.id, reactions[reaction.emojiHash])
	
	if tonumber(embeds.reactions[reaction.emojiHash]) then
		actions[antiAction(embedData.action)](reaction.message, {embedData.ids[(embedData.page-1) * 10 + embeds.reactions[reaction.emojiHash]]})
	elseif reaction.emojiHash == reactions.page then
		reaction.message.channel:broadcastTyping()
		local ids = {}
		for i = embedData.page*10 - 9, embedData.page*10 do
			if not embedData.ids[i] then break end
			table.insert(ids, embedData.ids[i])
		end
		actions[antiAction(embedData.action)](reaction.message, ids)
	elseif reaction.emojiHash == reactions.all then
		reaction.message.channel:broadcastTyping();
		actions[antiAction(embedData.action)](reaction.message, embedData.ids)
	end
end