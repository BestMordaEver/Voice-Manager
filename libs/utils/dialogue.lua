local commandFinalize = require "commands/commandFinalize"

local dialogue = {
	execute = function (self)
		
	end
}

local dialoguesIndex = {
	new = function (self, userID, context, guildID)
		-- new dialogues with the user nullify previous ones
		self[userID] = setmetatable({context = context, guildID = guildID},{__index = dialogue})
		return self[userID]
	end
}

local dialogues = setmetatable({},{
	__index = dialoguesIndex,
	__call = dialoguesIndex.new
})

return dialogues