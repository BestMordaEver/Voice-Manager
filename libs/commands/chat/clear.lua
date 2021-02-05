local locale = require "locale"

local hostCheck = require "funcs/hostCheck"
local hostPermissionCheck = require "funcs/hostPermissionCheck"

return function (message, chat, amount)
	local channel = hostCheck(message)
	if not channel then
		return "Not a host", "warning", locale.notHost
	end
	
	local isPermitted = hostPermissionCheck(message.member, channel, "manage")
	if not isPermitted then
		return "Insufficient permissions", "warning", locale.badHostPermission
	end
	
	amount = tonumber(amount)
	local trueAmount = 0
	
	if not amount then
		local first = chat:getFirstMessage()
		repeat
			local bulk = chat:getMessagesAfter(first, 100)
			if #bulk == 0 then
				chat:bulkDelete({first})
				trueAmount = trueAmount + 1
				break
			else
				chat:bulkDelete(bulk)
				trueAmount = trueAmount + #bulk
			end
		until false
	else
		repeat
			local bulk = chat:getMessages(amount > 100 and 100 or amount)
			trueAmount = trueAmount + #bulk
			chat:bulkDelete(bulk)
			amount = amount > 100 and amount - 100 or 0
		until amount == 0
	end
	
	return "Successfully cleared "..trueAmount.." messages", "ok", locale.clearConfirm:format(trueAmount)
end