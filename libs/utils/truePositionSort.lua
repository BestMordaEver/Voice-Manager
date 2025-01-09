local channelType = require "discordia".enums.channelType

-- returns channels in the same order they are presented in the app
-- https://imgur.com/a/hRWM73c
return function (a, b)
	if a.category and not b.category then
		return true
	elseif not a.category and b.category then
		return false
	elseif a.category ~= b.category then
		return a.category.position < b.category.position
	elseif a.type ~= channelType.voice and a.type ~= channelType.stageVoice and (b.type == channelType.voice or b.type == channelType.stageVoice) then
		return true
	elseif (a.type == channelType.voice or a.type == channelType.stageVoice) and b.type ~= channelType.voice and b.type ~= channelType.stageVoice then
		return false
	elseif a.position ~= b.position then
		return a.position < b.position
	else
		return a.createdAt < b.createdAt
	end
end