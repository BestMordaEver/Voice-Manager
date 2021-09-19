return function (template, member, position, replacement)
	local uname = member.user.name
	local nickname = member.nickname or uname
	local game = (member.activity and (member.activity.type == 0 or member.activity.type == 1)) and member.activity.name or 
		(template:match("%%game%((.-)%)%%" or "no game"))
	
	template = template:gsub("%%game%(.-%)%%", "%%game%%")
	
	local rt = {
		nickname = nickname,
		name = uname,
		tag = member.user.tag,
		game = game,
		counter = position,
		["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
		["name's"] = uname .. (uname:sub(-1,-1) == "s" and "'" or "'s"),
		rename = replacement or ""
	}
	return template:gsub("%%(.-)%%", rt), nil
end