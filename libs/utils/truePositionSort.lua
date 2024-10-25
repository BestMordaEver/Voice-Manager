local channelType = require "discordia".enums.channelType

-- returns channels in the same order they are presented in the app
-- https://imgur.com/a/hRWM73c
return function (a, b)
	return (not a.category and b.category) or
		(a.category and b.category and a.category.position < b.category.position) or
		(a.category == b.category and
			((a.type ~= channelType.voice and a.type ~= channelType.stageVoice and (b.type == channelType.voice or b.type == channelType.stageVoice)) or
			a.position < b.position or a.createdAt < b.createdAt))
end