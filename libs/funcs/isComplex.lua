local complex = {
	template = true,
	target = true,
	permissions = true,
	capacity = true,
	companion = true
}

return function (command) return complex[command] end