local commandFinalize = require "commands/commandFinalize"

--[[
dialogue = {
	guildID
	selected = lobbyID OR categoryID
	command = [server][lobbies][companions][matchmaking]
	subcommand = ...
	argument = ...
	toggle = [on][off]
]]

local dialogue = {
	execute = function (self)
		
	end
}

local dialoguesIndex = {
	new = function (self, userID, guildID)
		-- new dialogues with the user nullify previous ones
		self[userID] = setmetatable({guildID = guildID},{__index = dialogue})
		return self[userID]
	end
}

local dialogues = setmetatable({},{
	__index = dialoguesIndex,
	__call = dialoguesIndex.new
})

return dialogues