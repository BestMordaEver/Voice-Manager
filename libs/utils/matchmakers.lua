return {
	random = function (channels)
		return channels[math.random(#channels)]
	end,
	
	max = function (channels)
		local max = channels[1]
		for i, channel in pairs(channels) do
			if #max.connectedMembers < #channel.connectedMembers then
				max = channel
			end
		end
		return max
	end,
	
	min = function (channels)
		local min = channels[1]
		for i, channel in pairs(channels) do
			if #min.connectedMembers > #channel.connectedMembers then
				min = channel
			end
		end
		return min
	end,
	
	first = function (channels)
		return channels[1]
	end,
	
	last = function (channels)
		return channels[#channels]
	end
}