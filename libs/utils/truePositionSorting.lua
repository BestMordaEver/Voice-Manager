-- returns channels in the same order they are presented in the app
-- https://imgur.com/a/hRWM73c
return function (a, b)
	return (not a.category and b.category) or
		(a.category and b.category and a.category.position < b.category.position) or
		(a.category == b.category and a.position < b.position)
end