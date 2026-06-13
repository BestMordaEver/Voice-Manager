-- shared UTC offset parsing/formatting for transcript timestamps
local offset = {}

function offset.format(offsetMinutes)
	local sign = offsetMinutes < 0 and "-" or "+"
	offsetMinutes = math.abs(offsetMinutes)
	local hours = math.floor(offsetMinutes / 60)
	local minutes = offsetMinutes % 60
	return string.format("%s%02d:%02d", sign, hours, minutes)
end

function offset.parse(raw)
	raw = tostring(raw or ""):upper():gsub("UTC", ""):gsub("%s+", "")
	if raw == "" or raw == "Z" or raw == "+0" or raw == "-0" or raw == "+00:00" or raw == "-00:00" or raw == "0" then
		return 0
	end

	local sign, hours, minutes = raw:match("^([+-])(%d%d?):?(%d%d)$")
	if sign then
		hours = tonumber(hours)
		minutes = tonumber(minutes)
		if hours and minutes and minutes < 60 then
			local total = hours * 60 + minutes
			if total <= 14 * 60 then
				return sign == "-" and -total or total
			end
		end
	end

	sign, hours = raw:match("^([+-])(%d%d?)$")
	if sign then
		hours = tonumber(hours)
		if hours and hours <= 14 then
			local total = hours * 60
			return sign == "-" and -total or total
		end
	end

	return nil
end

return offset
