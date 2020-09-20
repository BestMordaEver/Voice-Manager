local client = require "discordia".storage.client

-- returns a table with IDs parsed from line and a boolean if there are several channels with given name (if given)
-- line may be a bunch of channel IDs or a channel name
return function (guild, line)
	local ids = {}
	if line then
		line = line:lower()
	
		if guild then
			for _, channel in pairs(guild.voiceChannels) do
				if channel.name:lower() == line then
					table.insert(ids, channel.id)
				end
			end
		end
		
		if #ids > 2 then
			return ids, true
		elseif #ids == 0 then
			for id in line:gmatch("%d+") do
				if client:getChannel(id) then table.insert(ids,id) end
			end
		end
	end
	return ids
end