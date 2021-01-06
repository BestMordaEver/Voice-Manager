return setmetatable({},{
	__call = function (self, userID, selected)
		-- new dialogues with the user nullify previous ones
		self[userID] = selected
	end
})