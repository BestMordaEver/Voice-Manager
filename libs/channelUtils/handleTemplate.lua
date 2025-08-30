return function (template, member, position, replacement)
	local uname = member.user.name
	local nickname = member.nickname or uname
	local game =
		member.playing and member.playing.name or
		(member.streaming and member.streaming.name) or
		(member.competing and member.competing.name) or
		template:match("%%game%((.-)%)%%") or "no game"
	local standin = replacement or template:match("%%rename%((.-)%)%%") or ""

	template = template:gsub("%%game%(.-%)%%", game:demagic()):gsub("%%rename%(.-%)%%", standin:demagic())

	local rt = {
		nickname = nickname,
		name = uname,
		tag = member.user.username,
		game = game,
		counter = position,
		["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
		["name's"] = uname .. (uname:sub(-1,-1) == "s" and "'" or "'s"),
		rename = replacement or standin
	}
	return template:gsub("%%(.-)%%", rt), nil
end