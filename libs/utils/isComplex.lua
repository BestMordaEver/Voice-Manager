local complex = {
	template = true,
	target = true,
	permissions = true,
	capacity = true,
	companion = true
}

return function (action) return complex[action] end